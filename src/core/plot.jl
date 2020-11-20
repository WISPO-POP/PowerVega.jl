

using Colors
properties = Dict("color" => Dict("bus" => colorant"green", "gen" => colorant"blue"))

function plot_network(case)
    layout_graph_vega!(case)
    df = form_df(case)
    p = @vlplot(
        width=500,
        height=500,
        config={view={stroke=nothing}},
        x={axis=nothing},
        y={axis=nothing},
        color={
            :ComponentType,
            scale={
                domain=[
                    "branch","bus","gen","connector",
                ],
                range=[
                    :green,
                    :blue,
                    :red,
                    :gray
                    # "rgb(137,78,36)",
                    # "rgb(220,36,30)",
                    # "rgb(255,206,0)",
                    # "rgb(1,114,41)",
                    # "rgb(0,175,173)",
                    # "rgb(215,153,175)",
                    # "rgb(106,114,120)",
                    # "rgb(114,17,84)",
                    # "rgb(0,0,0)",
                    # "rgb(0,24,168)",
                    # "rgb(0,160,226)",
                    # "rgb(106,187,170)"
                ]
            }
        },
    ) +
    @vlplot(
        mark ={
            :rule,
            "tooltip" =("content" => "data"),
            opacity =  1.0
        },
        data=df["branch"],
        x = :x,
        x2 = :x2,
        y = :y,
        y2 = :y2,
        size={value=5},
    ) +
    @vlplot(
        mark ={
            :rule,
            "tooltip" =("content" => "data"),
            # "tooltip" = true,
            opacity =  1.0
        },
        data=df["connector"],
        x = :x,
        x2 = :x2,
        y = :y,
        y2 = :y2,
        size={value=3},
        strokeDash={value=[4,4]}
    ) +
    @vlplot(
        data = df["bus"],
        mark ={
            :circle,
            "tooltip" =("content" => "data"),
            opacity =  1.0
        },
        x={:x,},
        y={:y,},
        size={value=1e2},
    )+
    @vlplot(
        data = df["gen"],
        mark ={
            :circle,
            "tooltip" =("content" => "data"),
            opacity =  1.0
        },
        x={:x,},
        y={:y,},
        size={value=5e1},
    )
    return p
end