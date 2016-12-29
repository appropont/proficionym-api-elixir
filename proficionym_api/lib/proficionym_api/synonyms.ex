defmodule ProficionymApi.SynonymsService do
  
  def getSynonyms(word) do
    if cachedSynonyms = get_cached_synonyms(word) do
      IO.puts "getting cached synonyms"
      String.split(cachedSynonyms, ",")
    else
      IO.puts "fetching synonyms"
      wordnik_task = Task.async(fn -> get_wordnik_api_synonyms(word) end)
      dictionary_task = Task.async(fn -> get_dictionary_api_synonyms(word) end)
      synonyms = Enum.sort(Enum.uniq(Task.await(wordnik_task) ++ Task.await(dictionary_task)))
      set_cached_synonyms(word, Enum.join(synonyms, ","))
    end
  end

  ###
  # Private functions
  ###
  defp get_wordnik_api_synonyms(word) do
    key = Application.get_env(:proficionym_api, :wordnik_api_key) || "testing"
    url = "https://api.wordnik.com/v4/word.json/" <> word <> "/relatedWords?useCanonical=false&limitPerRelationshipType=100&api_key=" <> key
    response = HTTPotion.get url
    parsed_result = Poison.Parser.parse!(response.body)

    Enum.reduce(parsed_result, [], fn (result_set, acc) ->
      # I feel like I should be using a map (or some other key/value store) for constant lookups instead of the likely linear lookup of the "in" (unless the compiler is that smart)
      if result_set["relationshipType"] in [
        "equivalent",
        "verb-form",
        "hypernym",
        "variant",
        "synonym",
        "same-context"
      ] do
          acc ++ result_set["words"]
      else
          acc
      end
    end)

  end

  defp get_dictionary_api_synonyms(word) do
    key = Application.get_env(:proficionym_api, :thesaurus_api_key) || "testing"
    url = "http://www.dictionaryapi.com/api/v1/references/thesaurus/xml/" <> word <> "?key=" <> key
    response = HTTPotion.get url
    {:ok, parsed_result, _} = :erlsom.parse_sax(response.body, nil, &parse_dictionary_api_xml/2)

    # a tokenized single pass parser would be much better than multiple regexes
    result_after_removals = Regex.replace(~r/(\s|\[\]|-)/, parsed_result.words, "")
    result_after_semicolons = Regex.replace(~r/;/, result_after_removals, ",")
    result_after_parens = Regex.replace(~r/ *\([^)]*\) */, result_after_semicolons, "")
    String.split(result_after_parens, ",")
  end
  
  ###
  # Below are methods and a struct used to parse the XML from dictionaryapi.com
  ###
  defmodule SaxState do
    defstruct words: "", should_capture: false
  end

  defp parse_dictionary_api_xml(:startDocument, _state) do
    %SaxState{words: ""}
  end
  
  defp parse_dictionary_api_xml({:startElement, _, 'syn', _, _}, state) do
    %{state | should_capture: true}
  end

  defp parse_dictionary_api_xml({:startElement, _, 'rel', _, _}, state) do
    %{state | should_capture: true}
  end

  defp parse_dictionary_api_xml({:characters, value}, %SaxState{words: words} = state) do
    if state.should_capture do
      words_string = to_string words
      words_string = 
        if words_string != "" do
          words_string = words_string <> ","
        else
          words_string
        end
      newWords = words_string <> to_string value
      state = %{state | words: newWords}
    else
        state
    end
  end

  defp parse_dictionary_api_xml({:endElement, _, 'syn', _}, state) do
    %{state | should_capture: false}
  end

  defp parse_dictionary_api_xml({:endElement, _, 'rel', _}, state) do
    %{state | should_capture: false}
  end

  defp parse_dictionary_api_xml(:endDocument, state), do: state
  defp parse_dictionary_api_xml(_, state), do: state


  defp get_cached_synonyms(word) do
    ProficionymApi.Redix.command!(~w(GET synonyms:#{word}))
  end

  defp set_cached_synonyms(word, synonyms) do
    redis_synonyms_expiration = 60 * 60 * 24 * 180
    command = [
      "SETEX",
      "synonyms:" <> word,
      redis_synonyms_expiration,
      synonyms
    ]
    ProficionymApi.Redix.command!(command)
    synonyms
  end

end
