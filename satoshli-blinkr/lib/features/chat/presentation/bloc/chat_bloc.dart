import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository chatRepository;

  ChatBloc({
    required this.sendMessageUseCase,
    required this.chatRepository,
  }) : super(ChatInitial()) {
    on<ChatLoadConversations>(_onLoadConversations);
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendMessage>(_onSendMessage);
  }

  Future<void> _onLoadConversations(
    ChatLoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    
    final result = await chatRepository.getConversations();
    
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversations) => emit(ChatConversationsLoaded(conversations)),
    );
  }

  Future<void> _onLoadMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    
    final result = await chatRepository.getMessages(event.conversationId);
    
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(ChatMessagesLoaded(messages: messages)),
    );
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final result = await sendMessageUseCase(
      conversationId: event.conversationId,
      content: event.content,
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (message) {
        // Recargar mensajes
        add(ChatLoadMessages(event.conversationId));
      },
    );
  }
}
