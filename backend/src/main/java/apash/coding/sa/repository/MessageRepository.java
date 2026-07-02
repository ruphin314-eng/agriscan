package apash.coding.sa.repository;

import apash.coding.sa.entites.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository
        extends JpaRepository<Message, Integer> {

    List<Message> findByConversationIdOrderByDateEnvoiAsc(
            Integer conversationId);
}