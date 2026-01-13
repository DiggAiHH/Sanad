"""
Chat router.

Handles chat rooms and messages.
"""

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import RequireStaff, get_current_user
from app.models.models import ChatMessage, ChatRoom, User, UserRole
from app.schemas.schemas import (
    ChatMessageCreate,
    ChatMessageListResponse,
    ChatMessageResponse,
    ChatRoomCreate,
    ChatRoomListResponse,
    ChatRoomResponse,
    MessageResponse,
)
from app.services.chat_service import (
    create_chat_room,
    get_chat_room,
    get_room_messages,
    get_unread_count,
    get_user_chat_rooms,
    is_room_participant,
    mark_messages_as_read,
    send_message,
)


router = APIRouter()


@router.get("/rooms", response_model=ChatRoomListResponse)
async def list_chat_rooms(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ChatRoomListResponse:
    """
    List all chat rooms for the current user.
    
    Args:
        db: Database session.
        current_user: Authenticated user.
        
    Returns:
        ChatRoomListResponse: List of chat rooms.
    """
    rooms = await get_user_chat_rooms(db, current_user.id)
    
    # Add unread counts
    room_responses = []
    for room in rooms:
        unread = await get_unread_count(db, room.id, current_user.id)
        last_message = room.messages[0] if room.messages else None
        
        room_response = ChatRoomResponse(
            id=room.id,
            name=room.name,
            is_group=room.is_group,
            created_at=room.created_at,
            updated_at=room.updated_at,
            unread_count=unread,
            last_message=ChatMessageResponse(
                id=last_message.id,
                room_id=last_message.room_id,
                sender_id=last_message.sender_id,
                content=last_message.content,
                is_read=last_message.is_read,
                created_at=last_message.created_at,
            ) if last_message else None,
        )
        room_responses.append(room_response)
    
    return ChatRoomListResponse(items=room_responses, total=len(room_responses))


@router.get("/rooms/{room_id}", response_model=ChatRoomResponse)
async def get_chat_room_by_id(
    room_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ChatRoom:
    """
    Get a specific chat room.
    
    Args:
        room_id: Chat room UUID.
        db: Database session.
        current_user: Authenticated user.
        
    Returns:
        ChatRoomResponse: Chat room data.
    """
    if not await is_room_participant(db, room_id, current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Teilnehmer dieses Chats",
        )
    
    room = await get_chat_room(db, room_id)
    
    if not room:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat-Raum nicht gefunden",
        )
    
    return room


@router.post("/rooms", response_model=ChatRoomResponse, status_code=status.HTTP_201_CREATED)
async def create_new_chat_room(
    request: ChatRoomCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ChatRoom:
    """
    Create a new chat room.
    
    Args:
        request: Chat room creation data.
        db: Database session.
        current_user: Authenticated user.
        
    Returns:
        ChatRoomResponse: Created chat room.
    """
    # Only staff can create chat rooms
    if current_user.role not in [UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA, UserRole.STAFF]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Keine Berechtigung zum Erstellen von Chat-Räumen",
        )
    
    room = await create_chat_room(db, request, current_user.id)
    return room


@router.get("/rooms/{room_id}/messages", response_model=ChatMessageListResponse)
async def list_room_messages(
    room_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
) -> ChatMessageListResponse:
    """
    List messages in a chat room.
    
    Args:
        room_id: Chat room UUID.
        db: Database session.
        current_user: Authenticated user.
        page: Page number.
        page_size: Items per page.
        
    Returns:
        ChatMessageListResponse: Paginated list of messages.
    """
    if not await is_room_participant(db, room_id, current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Teilnehmer dieses Chats",
        )
    
    offset = (page - 1) * page_size
    messages, total = await get_room_messages(db, room_id, page_size, offset)
    
    return ChatMessageListResponse(
        items=messages,
        total=total,
        page=page,
        page_size=page_size,
    )


@router.post("/rooms/{room_id}/messages", response_model=ChatMessageResponse, status_code=status.HTTP_201_CREATED)
async def send_chat_message(
    room_id: uuid.UUID,
    request: ChatMessageCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ChatMessage:
    """
    Send a message to a chat room.
    
    Args:
        room_id: Chat room UUID.
        request: Message data.
        db: Database session.
        current_user: Authenticated user.
        
    Returns:
        ChatMessageResponse: Sent message.
    """
    # Override room_id from URL
    message_data = ChatMessageCreate(
        room_id=room_id,
        content=request.content,
    )
    
    try:
        message = await send_message(db, message_data, current_user.id)
        return message
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e),
        )


@router.post("/rooms/{room_id}/read", response_model=MessageResponse)
async def mark_room_as_read(
    room_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Mark all messages in a room as read.
    
    Args:
        room_id: Chat room UUID.
        db: Database session.
        current_user: Authenticated user.
        
    Returns:
        MessageResponse: Confirmation.
    """
    if not await is_room_participant(db, room_id, current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Teilnehmer dieses Chats",
        )
    
    await mark_messages_as_read(db, room_id, current_user.id)
    return MessageResponse(message="Nachrichten als gelesen markiert")
