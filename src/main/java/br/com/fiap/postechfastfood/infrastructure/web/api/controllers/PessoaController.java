package br.com.fiap.postechfastfood.infrastructure.web.api.controllers;

import br.com.fiap.postechfastfood.domain.services.PessoaService;
import br.com.fiap.postechfastfood.dtos.PessoaRequestDto;
import br.com.fiap.postechfastfood.dtos.PessoaResponseDto;
import br.com.fiap.postechfastfood.infrastructure.web.api.dtos.PessoaRestDto;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class PessoaController {

    private final PessoaService pessoaService;

    public PessoaController(PessoaService pessoaService) {
        this.pessoaService = pessoaService;
    }

    @PostMapping("/v1/pessoa")
    public ResponseEntity<?> cadastrarPessoa(@Valid @RequestBody PessoaRestDto pessoaRequestDto) {
        PessoaResponseDto cpfEncontrado = pessoaService.buscarPorCdDocPessoa(pessoaRequestDto.cdDocPessoa());
        if (cpfEncontrado != null) {
            Map<String,String> error = new HashMap<>();
            error.put("error", "Cliente já cadastrado com o CPF informado");
            return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
        }
        PessoaResponseDto pessoaResponseDto = pessoaService.cadastrarPessoa(toRequest(pessoaRequestDto));
        return ResponseEntity.created(URI.create("/api/v1/pessoa/" + pessoaResponseDto.cdDocPessoa()))
                .body(pessoaResponseDto);
    }

    @GetMapping("/v1/pessoa/{cdDocPessoa}")
    public ResponseEntity<PessoaResponseDto> buscarPorCdDocPessoa(@PathVariable String cdDocPessoa) {
        PessoaResponseDto pessoaResponseDto = pessoaService.buscarPorCdDocPessoa(cdDocPessoa);
        return ResponseEntity.ok(pessoaResponseDto);
    }

    private PessoaRequestDto toRequest(PessoaRestDto dto) {
        return new PessoaRequestDto(dto.cdDocPessoa(), dto.nmPessoa(), dto.tpPessoa(), dto.dsEmail());
    }

    public PessoaRestDto toRestRequestDto(PessoaRequestDto dto) {
        return new PessoaRestDto(dto.cdDocPessoa(), dto.nmPessoa(), dto.tpPessoa(), dto.dsEmail());
    }
}
