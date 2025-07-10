package br.com.fiap.postechfasfood.gateways;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import br.com.fiap.postechfasfood.entities.ProdutoVO;
import br.com.fiap.postechfasfood.interfaces.ProdutoGatewayInterface;
import br.com.fiap.postechfasfood.interfaces.ProdutoRepositoryInterface;
import br.com.fiap.postechfasfood.types.TipoCategoriaProdutoEnum;



@Service
public class ProdutoGateway implements ProdutoGatewayInterface {

    private final ProdutoRepositoryInterface produtoRepository;

    public ProdutoGateway(ProdutoRepositoryInterface produtoRepository) {
        this.produtoRepository = produtoRepository;
    }

    
    public void cadastrar(ProdutoVO produto) {
        produto.setCdProduto(UUID.randomUUID());
        produtoRepository.cadastrar(produto);
    }

    public void atualizar(UUID cdProduto, ProdutoVO produto) {
        produto.setCdProduto(cdProduto);
        produtoRepository.atualizar(cdProduto, produto);
    }

    public void desativar(UUID cdProduto) {
        produtoRepository.desativar(cdProduto);
    }

    public void ativar(UUID cdProduto) {
        produtoRepository.ativar(cdProduto);
    }

    public List<ProdutoVO> listar() {
        return produtoRepository.listar();
    }

    public List<ProdutoVO> listar(TipoCategoriaProdutoEnum tpCategoria) {
        return produtoRepository.listar(tpCategoria);
    }

    public ProdutoVO buscarPorCdProduto(UUID cdProduto) {
        return produtoRepository.buscarPorCdProduto(cdProduto);
    }

}