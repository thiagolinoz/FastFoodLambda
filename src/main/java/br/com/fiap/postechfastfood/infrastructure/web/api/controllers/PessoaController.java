package br.com.fiap.postechfastfood.infrastructure.web.api.controllers;

import br.com.fiap.postechfastfood.domain.services.PessoaService;
import br.com.fiap.postechfastfood.infrastructure.web.api.dtos.PessoaRequestDto;
import br.com.fiap.postechfastfood.infrastructure.web.api.dtos.PessoaResponseDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;

@RestController
@RequestMapping("/api")
public class PessoaController {

    private final PessoaService pessoaService;

    public PessoaController(PessoaService pessoaService) {
        this.pessoaService = pessoaService;
    }

    @PostMapping("/v1/pessoa")
    public ResponseEntity<PessoaResponseDto> cadastrarPessoa(@RequestBody PessoaRequestDto pessoaRequestDto) {
        PessoaResponseDto pessoaResponseDto = pessoaService.cadastrarPessoa(pessoaRequestDto);
        return ResponseEntity.created(URI.create("/api/v1/pessoa/" + pessoaResponseDto.cdDocPessoa()))
                .body(pessoaResponseDto);
    }

    private PessoaRequestDto toRequest(PessoaResponseDto dto) {
        return new PessoaRequestDto(dto.cdDocPessoa(), dto.nmPessoa(), dto.tpPessoa(), dto.dsEmail());
    }

    public PessoaResponseDto toResponse(PessoaRequestDto dto) {
        return new PessoaResponseDto(dto.cdDocPessoa(), dto.nmPessoa(), dto.tpPessoa(), dto.dsEmail());
    }
}
