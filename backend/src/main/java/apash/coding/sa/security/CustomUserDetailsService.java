// security/CustomUserDetailsService.java
package apash.coding.sa.security;

import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import apash.coding.sa.entites.Client;
import apash.coding.sa.repository.ClientRepository;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final ClientRepository clientRepository;

    public CustomUserDetailsService(ClientRepository clientRepository) {
        this.clientRepository = clientRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email)
            throws UsernameNotFoundException {

        Client client = clientRepository.findByEmail(email)
            .orElseThrow(() ->
                new UsernameNotFoundException("Utilisateur introuvable : " + email));

        return User.builder()
            .username(client.getEmail())
            .password(client.getPassword())
            .roles("USER")
            .build();
    }
}