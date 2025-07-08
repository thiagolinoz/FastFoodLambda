package br.com.fiap.postechfasfood.externals;

import br.com.fiap.postechfasfood.gateways.entities.PessoaEntity;
import br.com.fiap.postechfasfood.interfaces.DbConnection;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

@Service
public class DbConnectionMariaDBImp implements DbConnection {
    @PersistenceContext
    private EntityManager em;

    @Override
    @Transactional
    public void CriarPessoa(PessoaEntity pessoaEntity) {
        em.merge(pessoaEntity);
    }

}
