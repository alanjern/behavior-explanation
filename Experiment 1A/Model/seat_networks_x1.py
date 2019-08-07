
def seat_near_a():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0]}], "props":{"k":0.5, "near_far":[[0,1,"loc_a"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]

def seat_far_c():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,2]}], "props":{"k":0.5, "near_far":[[1,-1,"loc_c"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_near_a_far_c():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0,2]}], "props":{"k":0.5, "near_far":[[0,1,"loc_a"],[1,-1,"loc_c"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_near_a_far_b_far_c():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0,1,2]}], "props":{"k":1, "near_far":[[0,1,"loc_a"],[1,-1,"loc_b"],[1,-1,"loc_c"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_near_a_far_b():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0,1]}], "props":{"k":0.5, "near_far":[[0,1,"loc_a"], [1,-1,"loc_b"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_far_b():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,1]}], "props":{"k":0.5, "near_far":[[1,-1,"loc_b"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_far_b_far_c():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,1,2]}], "props":{"k":0.5, "near_far":[[1,-1,"loc_b"],[1,-1,"loc_c"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_far_a():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0]}], "props":{"k":0.5, "near_far":[[1,-1,"loc_a"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_near_b_far_c():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,1,2]}], "props":{"k":0.5, "near_far":[[0,1,"loc_b"],[1,-1,"loc_c"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_near_a_near_b_far_c():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0,1,2]}], "props":{"k":0.5, "near_far":[[0,1,"loc_a"],[0,1,"loc_b"],[1,-1,"loc_c"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_near_a_near_b():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0,1]}], "props":{"k":0.5, "near_far":[[0,1,"loc_a"],[0,1,"loc_b"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_near_b():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,1]}], "props":{"k":0.5, "near_far":[[0,1,"loc_b"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]


def seat_far_a_far_c():
    net = '{"nodes":[{"id":0,"type":"chance","name":"loc_a","CPT":[{"event":["loc_a:1"],"prob":1}],"parents":[]},{"id":1,"type":"chance","name":"loc_b","CPT":[{"event":["loc_b:5"],"prob":1}],"parents":[]},{"id":2,"type":"chance","name":"loc_c","CPT":[{"event":["loc_c:9"],"prob":1}],"parents":[]},{"id":3,"type":"decision","name":"seat_choice","parents":[2,3,4],"values":["2","3"]},{"id":4,"type":"utility","name":"u","U":"utility_seating", "parents":[3,0,2]}], "props":{"k":0.5, "near_far":[[1,-1,"loc_a"],[1,-1,"loc_c"]]}}'

    decisions = '{"seat_choice":2, "other_options":[3,4,6,7,8]}'
    knowledge = '{"loc_a":1, "loc_b":5, "loc_c":9}'

    return [net, decisions, knowledge]
