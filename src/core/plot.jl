

# using Colors
# properties = Dict("color" => Dict("bus" => colorant"green", "gen" => colorant"blue"))

function plot_network(case)
    data = layout_graph_vega(case)
    df = form_df(data)
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
        x = :xcoord_1,
        x2 = :xcoord_2,
        y = :ycoord_1,
        y2 = :ycoord_2,
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
        x = :xcoord_1,
        x2 = :xcoord_2,
        y = :ycoord_1,
        y2 = :ycoord_2,
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
        x={:xcoord_1,},
        y={:ycoord_1,},
        size={value=1e2},
    )+
    @vlplot(
        data = df["gen"],
        mark ={
            :circle,
            "tooltip" =("content" => "data"),
            opacity =  1.0
        },
        x={:xcoord_1,},
        y={:ycoord_1,},
        size={value=5e1},
    )
    return p
end


function plot_power_flow(case)

    for (gen_id,gen) in case["gen"]
        if !haskey(gen,"pg")
            @warn "Generator $(gen_id) does not have key `pg`"
        end
    end
    for (branch_id,branch) in case["branch"]
        if !haskey(branch,"pt")
            @warn "Branch $(branch_id) does not have key `pt`"
        end
        if !haskey(branch,"pf")
            @warn "Branch $(branch_id) does not have key `pf`"
        end
    end
    for (bus_id,bus) in case["bus"]
        if !haskey(bus,"vm")
            @warn "Bus $(bus_id) does not have key `vm`"
        end
    end


    data = layout_graph_vega(case)
    df = form_df(data)
    p = @vlplot(
        width=500,
        height=500,
        config={view={stroke=nothing}},
        x={axis=nothing},
        y={axis=nothing},
        color={"PercentRated:q",scale={"range"= ["black", "black", "red"]},title="Percent of Rated Capacity"}
    ) +
    @vlplot(
        mark ={
            :rule,
            "tooltip" =("content" => "data"),
            opacity =  1.0
        },
        data=df["branch"],
        transform=[
            {
                calculate="abs(datum.pf) /datum.rate_a * 100",
                as="PercentRated"
            }
        ],
        x = :xcoord_1,
        x2 = :xcoord_2,
        y = :ycoord_1,
        y2 = :ycoord_2,
        size={value=5},
    ) +
    @vlplot(
        mark ={
            :rule,
            "tooltip" =("content" => "data"),
            opacity =  1.0
        },
        data=df["connector"],
        x = :xcoord_1,
        x2 = :xcoord_2,
        y = :ycoord_1,
        y2 = :ycoord_2,
        size={value=3},
        strokeDash={value=[4,4]},
        color={value="gray"}
    ) +
    @vlplot(
        data = df["bus"],
        transform=[
            {
                calculate="abs(datum.vm) /( datum.vmax+datum.vmin) * 100",
                as="PercentRated"
            }
        ],
        mark ={
            :point,
            "tooltip" =("content" => "data"),
            opacity =  1.0,
            filled=true
        },
        x={:xcoord_1,},
        y={:ycoord_1,},
        size={value=2e2},
        shape="ComponentType"
    )+
    @vlplot(
        data = df["gen"],
        transform=[
            {
                calculate="abs(datum.pg) /datum.pmax * 100",
                as="PercentRated"
            }
        ],
        mark ={
            :point,
            "tooltip" =("content" => "data"),
            opacity =  1.0,
            filled=true
        },
        x={:xcoord_1,},
        y={:ycoord_1,},
        size={value=5e1},
        shape="ComponentType"
    )
    return p
end