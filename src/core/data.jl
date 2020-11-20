

"create a dataframe based on powermodels dictionary"
function form_df(case::Dict{String,<:Any};)

    if InfrastructureModels.ismultinetwork(case)
        Memento.error(_LOGGER, "form_df does not yet support multinetwork data")
    end

    data = deepcopy(case)

    df_return = Dict{String,DataFrame}()
    component_types = []
    metadata_key = Symbol[]
    metadata_val = Any[]

    #Network meta_data
    for (k,v) in sort(collect(data); by=x->x[1])
        if typeof(v) <: Dict && InfrastructureModels._iscomponentdict(v)
            push!(component_types, k)
        else
            push!(metadata_key,Symbol(k))
            push!(metadata_val,[v])
        end
    end
    df_return["metadata"] = DataFrame(metadata_val,metadata_key)

    for comp_type in component_types

        if length(data[comp_type]) <= 0 ## Should there be an empty dataframe, or a nonexistent dataframe?
            continue
        end

        components = data[comp_type]

        columns = [Symbol(k) => (typeof(v) <: Array || typeof(v) <: Dict) ? String[] : typeof(v)[] for (k,v) in first(components)[2]]

        df_return[comp_type] = DataFrame(columns...)
        for (i, component) in components
            for (k,v) in component
                if typeof(v) <: Array || typeof(v) <: Dict
                    component[k] = string(v)
                end
            end
            push!(df_return[comp_type], component)
        end

        df_return[comp_type][!,:ComponentType] .=comp_type
    end

    return df_return
end
