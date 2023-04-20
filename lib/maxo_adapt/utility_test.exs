defmodule MaxoAdapt.UtilityTest do
  use ExUnit.Case
  use Mneme, action: :accept, default_pattern: :last, force_update: false
  alias MaxoAdapt.Utility

  describe "analyze" do
    test "callbacks with when condition" do
      block =
        quote do
          @doc ""
          @doc group: "Schema API"
          @callback insert_all(
                      schema_or_source :: binary | {binary, module} | module,
                      entries_or_query :: [%{atom => value} | Keyword.t(value)] | Ecto.Query.t(),
                      opts :: Keyword.t()
                    ) :: {non_neg_integer, nil | [term]}
                    when value: term | Ecto.Query.t()
        end

      auto_assert(
        """
        @doc ""
        @doc group: "Schema API"
        @callback insert_all(
                    schema_or_source :: binary | {binary, module} | module,
                    entries_or_query :: [%{atom => value} | Keyword.t(value)] | Ecto.Query.t(),
                    opts :: Keyword.t()
                  ) :: {non_neg_integer, nil | [term]}
                  when value: term | Ecto.Query.t()\
        """ <- Macro.to_string(block)
      )

      {code, callbacks} = Utility.analyze(block)

      auto_assert(
        %{
          insert_all: %{
            args: [:schema_or_source, :entries_or_query, :opts],
            doc:
              {:@, [context: MaxoAdapt.UtilityTest, imports: [{1, Kernel}]],
               [{:doc, [context: MaxoAdapt.UtilityTest], [[group: "Schema API"]]}]},
            spec:
              {:@, [context: MaxoAdapt.UtilityTest, imports: [{1, Kernel}]],
               [
                 {:spec, [context: MaxoAdapt.UtilityTest],
                  [
                    {:when, [],
                     [
                       {:"::", [],
                        [
                          {:insert_all, [],
                           [
                             {:"::", [],
                              [
                                {:schema_or_source, [], MaxoAdapt.UtilityTest},
                                {:|, [],
                                 [
                                   {:binary, [], MaxoAdapt.UtilityTest},
                                   {:|, [],
                                    [
                                      {{:binary, [], MaxoAdapt.UtilityTest},
                                       {:module, [], MaxoAdapt.UtilityTest}},
                                      {:module, [], MaxoAdapt.UtilityTest}
                                    ]}
                                 ]}
                              ]},
                             {:"::", [],
                              [
                                {:entries_or_query, [], MaxoAdapt.UtilityTest},
                                {:|, [],
                                 [
                                   [
                                     {:|, [],
                                      [
                                        {:%{}, [],
                                         [
                                           {{:atom, [], MaxoAdapt.UtilityTest},
                                            {:value, [], MaxoAdapt.UtilityTest}}
                                         ]},
                                        {{:., [],
                                          [{:__aliases__, [alias: false], [:Keyword]}, :t]}, [],
                                         [{:value, [], MaxoAdapt.UtilityTest}]}
                                      ]}
                                   ],
                                   {{:., [],
                                     [{:__aliases__, [alias: false], [:Ecto, :Query]}, :t]}, [],
                                    []}
                                 ]}
                              ]},
                             {:"::", [],
                              [
                                {:opts, [], MaxoAdapt.UtilityTest},
                                {{:., [], [{:__aliases__, [alias: false], [:Keyword]}, :t]}, [],
                                 []}
                              ]}
                           ]},
                          {{:non_neg_integer, [], MaxoAdapt.UtilityTest},
                           {:|, [], [nil, [{:term, [], MaxoAdapt.UtilityTest}]]}}
                        ]},
                       [
                         value:
                           {:|, [],
                            [
                              {:term, [], MaxoAdapt.UtilityTest},
                              {{:., [], [{:__aliases__, [alias: false], [:Ecto, :Query]}, :t]},
                               [], []}
                            ]}
                       ]
                     ]}
                  ]}
               ]}
          }
        } <- callbacks
      )
    end

    test "simple callbacks" do
      block =
        quote do
          @doc ~S"A color's RGB value."
          @callback rgb :: {0..255, 0..255, 0..255}
        end

      {code, callbacks} = Utility.analyze(block)

      auto_assert(
        %{
          rgb: %{
            args: [],
            doc:
              {:@, [context: MaxoAdapt.UtilityTest, imports: [{1, Kernel}]],
               [
                 {:doc, [context: MaxoAdapt.UtilityTest],
                  [
                    {:sigil_S,
                     [delimiter: "\"", context: MaxoAdapt.UtilityTest, imports: [{2, Kernel}]],
                     [{:<<>>, [], ["A color's RGB value."]}, []]}
                  ]}
               ]},
            spec:
              {:@, [context: MaxoAdapt.UtilityTest, imports: [{1, Kernel}]],
               [
                 {:spec, [context: MaxoAdapt.UtilityTest],
                  [
                    {:"::", [],
                     [
                       {:rgb, [], MaxoAdapt.UtilityTest},
                       {:{}, [],
                        [
                          {:..,
                           [context: MaxoAdapt.UtilityTest, imports: [{0, Kernel}, {2, Kernel}]],
                           [0, 255]},
                          {:..,
                           [context: MaxoAdapt.UtilityTest, imports: [{0, Kernel}, {2, Kernel}]],
                           [0, 255]},
                          {:..,
                           [context: MaxoAdapt.UtilityTest, imports: [{0, Kernel}, {2, Kernel}]],
                           [0, 255]}
                        ]}
                     ]}
                  ]}
               ]}
          }
        } <- callbacks
      )
    end
  end
end
