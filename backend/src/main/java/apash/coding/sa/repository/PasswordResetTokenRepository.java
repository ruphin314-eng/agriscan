// repository/PasswordResetTokenRepository.java
package apash.coding.sa.repository;

import apash.coding.sa.entites.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Integer> {

    Optional<PasswordResetToken> findByToken(String token);

    void deleteByEmail(String email); // nettoyer les anciens tokens
}