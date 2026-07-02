// repository/ConversationRepository.java
package apash.coding.sa.repository;

import apash.coding.sa.entites.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

@Repository
public interface ConversationRepository
        extends JpaRepository<Conversation, Integer> {

    // Toutes les conversations d'un client triées par date
    @Query("SELECT c FROM Conversation c LEFT JOIN FETCH c.messages WHERE c.client.id = :clientId ORDER BY c.dateCreation DESC")
    List<Conversation> findByClientIdOrderByDateCreationDesc(@Param("clientId") Integer clientId);
}