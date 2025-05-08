package br.com.fiap.postechfastfood.domain.ports;

import br.com.fiap.postechfastfood.domain.models.PessoaModel;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PessoaRepositoryPort {

    PessoaModel cadastrarPessoa(PessoaModel pessoaModel);
    Optional<PessoaModel> buscarPorCdDocPessoa(String cdDocPessoa);
    List<PessoaModel> listarTodasPessoas();
    void removerPessoa(String cdDocPessoa);
}
