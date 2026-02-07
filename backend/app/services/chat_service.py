"""
Chat service for team communication.

Handles chat rooms, messages, and real-time updates.
"""

import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.models import ChatMessage, ChatParticipant, ChatRoom
from app.schemas.schemas import ChatMessageCreate, ChatRoomCreate


async def create_chat_room(
    db: AsyncSession,
    room_data: ChatRoomCreate,
    creator_id: uuid.UUID,
) -> ChatRoom:
    """
    Create a new chat room.

    Args:
        db: Database session.
        room_data: Chat room creation data.
        creator_id: ID of the user creating the room.

    Returns:
        ChatRoom: Created chat room.
    """
    room = ChatRoom(
        name=room_data.name,
        is_group=room_data.is_group,
    )
    db.add(room)
    await db.flush()

    # Add participants including creator
    participant_ids = set(room_data.participant_ids)
    participant_ids.add(creator_id)

    for user_id in participant_ids:
        participant = ChatParticipant(
            room_id=room.id,
            user_id=user_id,
        )
        db.add(participant)

    await db.commit()
    await db.refresh(room)
    return room


async def get_user_chat_rooms(db: AsyncSession, user_id: uuid.UUID) -> list[ChatRoom]:
    """
    Get all chat rooms for a user.

    Args:
        db: Database session.
        user_id: User UUID.

    Returns:
        list[ChatRoom]: List of chat rooms.
    """
    result = await db.execute(
        select(ChatRoom)
        .join(ChatParticipant)
        .where(ChatParticipant.user_id == user_id)
        .options(selectinload(ChatRoom.messages))
        .order_by(ChatRoom.updated_at.desc())
    )
    return list(result.scalars().unique().all())


async def get_chat_room(db: AsyncSession, room_id: uuid.UUID) -> Optional[ChatRoom]:
    """
    Get a chat room by ID.

    Args:
        db: Database session.
        room_id: Chat room UUID.

    Returns:
        ChatRoom: Chat room or None.
    """
    result = await db.execute(
        select(ChatRoom)
        .where(ChatRoom.id == room_id)
        .options(selectinload(ChatRoom.participants))
    )
    return result.scalar_one_or_none()


async def is_room_participant(
    db: AsyncSession, room_id: uuid.UUID, user_id: uuid.UUID
) -> bool:
    """
    Check if a user is a participant in a chat room.

    Args:
        db: Database session.
        room_id: Chat room UUID.
        user_id: User UUID.

    Returns:
        bool: True if user is a participant.
    """
    result = await db.execute(
        select(ChatParticipant)
        .where(ChatParticipant.room_id == room_id)
        .where(ChatParticipant.user_id == user_id)
    )
    return result.scalar_one_or_none() is not None


async def send_message(
    db: AsyncSession,
    message_data: ChatMessageCreate,
    sender_id: uuid.UUID,
) -> ChatMessage:
    """
    Send a message to a chat room.

    Args:
        db: Database session.
        message_data: Message creation data.
        sender_id: ID of the message sender.

    Returns:
        ChatMessage: Created message.

    Raises:
        ValueError: If user is not a room participant.
    """
    # Verify sender is a participant
    if not await is_room_participant(db, message_data.room_id, sender_id):
        raise ValueError("User is not a participant in this chat room")

    message = ChatMessage(
        room_id=message_data.room_id,
        sender_id=sender_id,
        content=message_data.content,
    )
    db.add(message)

    # Update room's updated_at
    room = await get_chat_room(db, message_data.room_id)
    if room:
        room.updated_at = datetime.now(timezone.utc)

    await db.commit()
    await db.refresh(message)
    return message


async def get_room_messages(
    db: AsyncSession,
    room_id: uuid.UUID,
    limit: int = 50,
    offset: int = 0,
) -> tuple[list[ChatMessage], int]:
    """
    Get messages for a chat room.

    Args:
        db: Database session.
        room_id: Chat room UUID.
        limit: Maximum number of messages.
        offset: Number of messages to skip.

    Returns:
        tuple: List of messages and total count.
    """
    query = (
        select(ChatMessage)
        .where(ChatMessage.room_id == room_id)
        .options(selectinload(ChatMessage.sender))
        .order_by(ChatMessage.created_at.desc())
        .limit(limit)
        .offset(offset)
    )

    count_query = select(func.count(ChatMessage.id)).where(
        ChatMessage.room_id == room_id
    )

    result = await db.execute(query)
    messages = list(result.scalars().all())

    count_result = await db.execute(count_query)
    total = count_result.scalar() or 0

    return messages, total


async def mark_messages_as_read(
    db: AsyncSession, room_id: uuid.UUID, user_id: uuid.UUID
) -> int:
    """
    Mark all messages in a room as read for a user.

    Args:
        db: Database session.
        room_id: Chat room UUID.
        user_id: User UUID.

    Returns:
        int: Number of messages marked as read.
    """
    # Update last_read_at for participant
    result = await db.execute(
        select(ChatParticipant)
        .where(ChatParticipant.room_id == room_id)
        .where(ChatParticipant.user_id == user_id)
    )
    participant = result.scalar_one_or_none()

    if participant:
        participant.last_read_at = datetime.now(timezone.utc)
        await db.commit()

    # Count unread messages (messages after last_read_at from other users)
    # For now, return 0 as we've marked all as read
    return 0


async def get_unread_count(
    db: AsyncSession, room_id: uuid.UUID, user_id: uuid.UUID
) -> int:
    """
    Get unread message count for a user in a room.

    Args:
        db: Database session.
        room_id: Chat room UUID.
        user_id: User UUID.

    Returns:
        int: Number of unread messages.
    """
    # Get participant's last_read_at
    result = await db.execute(
        select(ChatParticipant)
        .where(ChatParticipant.room_id == room_id)
        .where(ChatParticipant.user_id == user_id)
    )
    participant = result.scalar_one_or_none()

    if not participant:
        return 0

    # Count messages after last_read_at from other users
    query = (
        select(func.count(ChatMessage.id))
        .where(ChatMessage.room_id == room_id)
        .where(ChatMessage.sender_id != user_id)
    )

    if participant.last_read_at:
        query = query.where(ChatMessage.created_at > participant.last_read_at)

    count_result = await db.execute(query)
    return count_result.scalar() or 0
