

# const node_types = ["bus","gen","storage"]
# const edge_types = ["switch","branch","dcline","transformer"]


function layout_graph_vega!(case::Dict{String,Any};
    node_types::Array{String,1} = ["bus","gen","storage"],
    edge_types::Array{String,1} = ["switch","branch","dcline","transformer"],
    )

    data = deepcopy(case)
    node_comp_map = Dict()
    for node_type in node_types
        temp_node = get(data, node_type, Dict())
        temp_map = Dict(string(comp["source_id"][1],"_",comp["source_id"][2]) => comp  for (comp_id, comp) in temp_node)
        merge!(node_comp_map,temp_map)
    end

    edge_comp_map = Dict()
    for edge_type in edge_types
        temp_edge = get(data, edge_type, Dict())
        for (id,edge) in temp_edge
            edge["src"] = "bus_$(edge["f_bus"])"
            edge["dst"] = "bus_$(edge["t_bus"])"
        end
        temp_map = Dict(string(comp["source_id"][1],"_",comp["source_id"][2]) => comp for (comp_id, comp) in temp_edge)
        merge!(edge_comp_map,temp_map)
    end
    # connectors
    connector_map = Dict()
    for node_type in node_types
        if node_type!="bus"
            nodes = get(data, node_type, Dict())
            for (id,node) in nodes
                temp_connector = Dict()
                temp_connector["src"] = "$(node_type)_$(id)"
                temp_connector["dst"] = "bus_$(node["$(node_type)_bus"])"

                temp_map = Dict(string("connector_",(length(connector_map)+1)) => temp_connector)
                merge!(connector_map,temp_map)
            end
        end
    end

    # for node_type in node_types
    #     if node_type != "bus"
    #         connector_edge = get(data, node_type, Dict())
    #         for (id,edge) in connector_edge
    #             edge["src"] = string(edge["source_id"][1],"_",edge["source_id"][2])
    #             edge["dst"] = string("bus_",data["bus"][string(edge["$(node_type)_bus"])]["index"])
    #         end
    #         connector_map = Dict(string(comp["source_id"][1],"_",comp["source_id"][2],"_connector") => comp  for (comp_id, comp) in connector_edge)
    #         merge!(edge_comp_map,connector_map)
    #     end
    # end

    G = nx.Graph()
    for (id,node) in node_comp_map
        G.add_node(id)
    end
    for (id,edge) in edge_comp_map
        G.add_edge(edge["src"], edge["dst"], weight=1.0)
    end
    for (id,edge) in connector_map
        G.add_edge(edge["src"], edge["dst"], weight=0.2)
    end

    positions = nx.kamada_kawai_layout(G, dist=nothing, pos=nothing, weight="weight", scale=1.0, center=nothing, dim=2)

    # Set Node Positions
    for (node, (x, y)) in positions
        (comp_type,comp_id) = split(node, "_")
        case[comp_type][comp_id]["xcoord_1"] = x
        case[comp_type][comp_id]["ycoord_1"] = y
    end
    # Set Edge positions
    for (edge, val) in (edge_comp_map)
        (x,y) = positions[val["src"]]
        (x2,y2) = positions[val["dst"]]
        (comp_type,comp_id) = split(edge, "_")
        case[comp_type][comp_id]["xcoord_1"] = x
        case[comp_type][comp_id]["ycoord_1"] = y
        case[comp_type][comp_id]["xcoord_2"] = x2
        case[comp_type][comp_id]["ycoord_2"] = y2
    end

    # Create connector dictionary
    case["connector"] = Dict()
    for (edge, con) in connector_map
        _,id = split(edge, "_")
        case["connector"][id]=  Dict(
            "src" => con["src"],
            "dst" => con["dst"],
            "xcoord_1" => 0.0,
            "ycoord_1" => 0.0,
            "xcoord_2" => 0.0,
            "ycoord_2" => 0.0,
        )
    end
    # Set Connector positions
    for (edge, val) in (connector_map)
        (x,y) = positions[val["src"]]
        (x2,y2) = positions[val["dst"]]
        (comp_type,comp_id) = split(edge, "_")
        case[comp_type][comp_id]["xcoord_1"] = x
        case[comp_type][comp_id]["ycoord_1"] = y
        case[comp_type][comp_id]["xcoord_2"] = x2
        case[comp_type][comp_id]["ycoord_2"] = y2
    end
end