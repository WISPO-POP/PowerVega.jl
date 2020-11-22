

# using Colors
# properties = Dict("color" => Dict("bus" => colorant"green", "gen" => colorant"blue"))

function plot_network(case)
    data = layout_graph_vega(case)
    remove_information!(data)
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
            tooltip=("content" => "data"),
            opacity =  1.0
        },
        data=df["branch"],
        x = :xcoord_1,
        x2 = :xcoord_2,
        y = :ycoord_1,
        y2 = :ycoord_2,
        size={value=5},
        # tooltip={"xcoord_1:n"},
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
    remove_information!(data)
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

function remove_information!(data)
    # valid_keys = Dict("branch"  => ["xcoord_1", "xcoord_2", "ycoord_1", "ycoord_2", "pf", "src","dst","rate_a","index"], #["br_r", "mu_angmin", "mu_angmax", "rate_a", "mu_sf", "shift", "rate_b", "pt", "br_x", "rate_c", "g_to", "g_fr", "mu_st", "source_id", "f_bus", "b_fr", "br_status", "t_bus", "b_to", "index", "qf", "angmin", "angmax", "qt", "transformer", "tap", "pf"]
    #                   "bus"     => ["xcoord_1", "ycoord_1", "bus_type", "name", "vmax",  "vmin", "index", "va", "vm", "base_kv"], #"mu_vmax", "lam_q", "mu_vmin", "source_id", "area","lam_p","zone", "bus_i",
    #                   "gen"     => ["xcoord_1", "ycoord_1",  "pg", "qg", "gen_bus", "pmax",  "vg", "mbase", "index", "cost", "qmax", "gen_status", "qmin", "pmin", ] #"ncost", "qc1max","qc2max", "ramp_agc", "qc1min", "qc2min", "pc1", "ramp_q", "mu_qmax", "ramp_30", "mu_qmin","model", "shutdown", "startup","ramp_10","source_id", "mu_pmax", "pc2", "mu_pmin","apf",
    # )
    invalid_keys = Dict("branch"  => ["br_r", "mu_angmin", "mu_angmax", "mu_sf", "shift", "rate_b", "br_x", "rate_c", "g_to", "g_fr", "mu_st", "source_id", "f_bus", "b_fr", "br_status", "t_bus", "b_to", "qf", "angmin", "angmax", "qt", "transformer", "tap"],#["xcoord_1", "xcoord_2", "ycoord_1", "ycoord_2", "pf", "src","dst","rate_a","index"],
                        "bus"     => ["mu_vmax", "lam_q", "mu_vmin", "source_id", "area","lam_p","zone", "bus_i"],#["xcoord_1", "ycoord_1", "bus_type", "name", "vmax",  "vmin", "index", "va", "vm", "base_kv"],
                        "gen"     => ["ncost", "qc1max","qc2max", "ramp_agc", "qc1min", "qc2min", "pc1", "ramp_q", "mu_qmax", "ramp_30", "mu_qmin","model", "shutdown", "startup","ramp_10","source_id", "mu_pmax", "pc2", "mu_pmin","apf",],#["xcoord_1", "ycoord_1",  "pg", "qg", "gen_bus", "pmax",  "vg", "mbase", "index", "cost", "qmax", "gen_status", "qmin", "pmin", ]
    )
    for comp_type in ["bus","branch","gen"]
        for (id, comp) in data[comp_type]
            for key in keys(comp)
                if (key in invalid_keys[comp_type])
                    delete!(comp,key)
                end
            end
        end
    end
end