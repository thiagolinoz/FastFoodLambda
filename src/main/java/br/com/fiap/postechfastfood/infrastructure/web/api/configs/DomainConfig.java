package br.com.fiap.postechfastfood.infrastructure.web.api.configs;

import br.com.fiap.postechfastfood.domain.ports.PedidosRepositoryPort;
import br.com.fiap.postechfastfood.domain.ports.PessoaRepositoryPort;
import br.com.fiap.postechfastfood.domain.services.PedidoService;
import br.com.fiap.postechfastfood.domain.services.PessoaService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DomainConfig {

    @Bean
    public PessoaService pessoaService(PessoaRepositoryPort pessoaRepository) {
        return new PessoaService(pessoaRepository);
    }
    @Bean
    public PedidoService pedidosService(PedidosRepositoryPort pedidosRepositoryPort) {
        return new PedidoService(pedidosRepositoryPort);
    }

}
