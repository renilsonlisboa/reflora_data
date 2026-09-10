using HTTP
using JSON3
using DataFrames
using CSV

# Endpoint com a lista de famílias
url_familias = "https://servicos.jbrj.gov.br/v2/flora/families"

println("Buscando lista de famílias...")

# Faz a requisição inicial
response_familias = HTTP.get(url_familias)

# Converte o JSON recebido
lista_familias = JSON3.read(String(response_familias.body))

# Vetor que armazenará os resultados
resultados = NamedTuple[]

println("Total de famílias: $(length(lista_familias))")

for familia in lista_familias

    url = "https://servicos.jbrj.gov.br/v2/flora/species/$(familia)"

    try
        response = HTTP.get(url)

        # Verifica se a requisição foi bem-sucedida
        if response.status == 200

            data = JSON3.read(String(response.body))

            if data isa AbstractVector && !isempty(data)

                for registro in data

                    push!(
                        resultados,
                        (
                            Familia = get(registro, :family, missing),
                            Nome_Cientifico = get(registro, :scientificname, missing),
                            Status = get(registro, :taxonomicstatus, missing)
                        )
                    )

                end

            end

            println("✓ $(familia)")

        else
            println("Erro ao processar $(familia): HTTP $(response.status)")
        end

    catch e
        println("Erro ao processar $(familia): $(e)")
    end

    # Evita muitas requisições seguidas ao servidor
    sleep(0.5)

end

# Converte os resultados para DataFrame
df_resultados = DataFrame(resultados)

# Salva em CSV
CSV.write("dados_reflora.csv", df_resultados)

println()
println("Processamento concluído!")
println("Total de registros: $(nrow(df_resultados))")
println("Arquivo salvo em: dados_reflora.csv")
