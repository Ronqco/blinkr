import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;

  ChatBloc({required this.sendMessageUseCase}) : super(ChatInitial()) {
    on<ChatLoadConversations>(_onLoadConversations);
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendMessage>(_onSendMessage);
  }

  Future<void> _onLoadConversations(
    ChatLoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    // TODO: Implement
    emit(const ChatConversationsLoaded([]));
  }

  Future<void> _onLoadMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    // TODO: Implement
    emit(const ChatMessagesLoaded(messages: []));
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
        // Reload messages
        add(ChatLoadMessages(event.conversationId));
      },
    );
  }
}
