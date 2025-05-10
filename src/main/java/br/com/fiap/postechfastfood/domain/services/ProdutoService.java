package br.com.fiap.postechfastfood.domain.services;

import br.com.fiap.postechfastfood.domain.enums.TipoCategoriaProdutoEnum;
import br.com.fiap.postechfastfood.domain.models.ProdutoModel;
import br.com.fiap.postechfastfood.domain.ports.in.ProdutoServicePort;
import br.com.fiap.postechfastfood.domain.ports.out.ProdutoRepositoryPort;
import br.com.fiap.postechfastfood.infrastructure.web.api.dtos.ProdutoRequestDto;
import br.com.fiap.postechfastfood.infrastructure.web.api.dtos.ProdutoResponseDto;

import java.util.List;
import java.util.Optional;

public class ProdutoService implements ProdutoServicePort {

    private final ProdutoRepositoryPort produtoRepository;
    public ProdutoService(ProdutoRepositoryPort produtoRepository){this.produtoRepository = produtoRepository}

    @Override
    public ProdutoResponseDto cadastrar(ProdutoRequestDto produto) {
        return null;
    }

    @Override
    public ProdutoResponseDto atualizar(String cdProduto, ProdutoRequestDto produto) {
        return null;
    }

    @Override
    public void deletar(String cdProduto) {

    }

    @Override
    public Optional<List<ProdutoResponseDto>> buscar() {
        return Optional.empty();
    }

    @Override
    public Optional<List<ProdutoResponseDto>> buscar(TipoCategoriaProdutoEnum tpCategoria) {
        return Optional.empty();
    }
}
