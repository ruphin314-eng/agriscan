package apash.coding.sa.service;

import apash.coding.sa.dto.*;
import apash.coding.sa.entites.*;
import apash.coding.sa.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ConversationService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final ClientRepository clientRepository;

    private static final DateTimeFormatter FORMATTER =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    public ConversationService(
            ConversationRepository conversationRepository,
            MessageRepository messageRepository,
            ClientRepository clientRepository) {
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.clientRepository = clientRepository;
    }

    // ── Créer une conversation avec ses messages ───────────
    @Transactional
    public ConversationResponse creerConversation(
            ConversationRequest request) {

        Client client = clientRepository.findById(request.getClientId())
                .orElseThrow(() ->
                        new RuntimeException("Client introuvable"));

        // Créer la conversation
        Conversation conversation = new Conversation(
                request.getTitre(),
                request.getSaison(),
                client
        );
        conversation = conversationRepository.save(conversation);

        // Créer les messages
        final Conversation conv = conversation;
        List<Message> messages = request.getMessages().stream()
                .map(dto -> new Message(
                        dto.getRole(),
                        dto.getContenu(),
                        dto.getType(),
                        conv
                ))
                .collect(Collectors.toList());

        // Définir imageUrl si présent
        for (int i = 0; i < messages.size(); i++) {
            if (request.getMessages().get(i).getImageUrl() != null) {
                messages.get(i).setImageUrl(
                        request.getMessages().get(i).getImageUrl());
            }
        }

        messageRepository.saveAll(messages);

        return toResponse(conversation, messages);
    }

    // ── Ajouter un message à une conversation existante ────
    @Transactional
    public ConversationResponse ajouterMessage(
            Integer conversationId, MessageDto dto) {

        Conversation conversation = conversationRepository
                .findById(conversationId)
                .orElseThrow(() ->
                        new RuntimeException("Conversation introuvable"));

        Message message = new Message(
                dto.getRole(),
                dto.getContenu(),
                dto.getType(),
                conversation
        );
        if (dto.getImageUrl() != null) {
            message.setImageUrl(dto.getImageUrl());
        }
        messageRepository.save(message);

        List<Message> messages = messageRepository
                .findByConversationIdOrderByDateEnvoiAsc(conversationId);

        return toResponse(conversation, messages);
    }

    // ── Historique d'un client ─────────────────────────────
    public List<ConversationSummary> getHistorique(Integer clientId) {
        return conversationRepository
                .findByClientIdOrderByDateCreationDesc(clientId)
                .stream()
                .map(c -> new ConversationSummary(
                        c.getId(),
                        c.getTitre(),
                        c.getSaison(),
                        c.getDateCreation().format(FORMATTER),
                        c.getMessages() != null ? c.getMessages().size() : 0
                ))
                .collect(Collectors.toList());
    }

    // ── Détail d'une conversation ──────────────────────────
    public ConversationResponse getConversation(Integer id) {
        Conversation conversation = conversationRepository
                .findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Conversation introuvable"));

        List<Message> messages = messageRepository
                .findByConversationIdOrderByDateEnvoiAsc(id);

        return toResponse(conversation, messages);
    }

    // ── Supprimer une conversation ─────────────────────────
    @Transactional
    public void supprimer(Integer id) {
        if (!conversationRepository.existsById(id)) {
            throw new RuntimeException("Conversation introuvable");
        }
        conversationRepository.deleteById(id);
    }

    // ── Helper ────────────────────────────────────────────
    private ConversationResponse toResponse(
            Conversation conversation, List<Message> messages) {

        List<MessageDto> messageDtos = messages.stream()
                .map(m -> {
                    MessageDto dto = new MessageDto();
                    dto.setRole(m.getRole());
                    dto.setContenu(m.getContenu());
                    dto.setType(m.getType());
                    dto.setImageUrl(m.getImageUrl());
                    return dto;
                })
                .collect(Collectors.toList());

        return new ConversationResponse(
                conversation.getId(),
                conversation.getTitre(),
                conversation.getSaison(),
                conversation.getDateCreation().format(FORMATTER),
                messageDtos
        );
    }
}