import random


def generate_memory(size=1024, data_width=16, signed=True, random_range=True):

    if signed:
        absolute_min = -(2 ** (data_width - 1))
        absolute_max = (2 ** (data_width - 1)) - 1
    else:
        absolute_min = 0
        absolute_max = (2 ** data_width) - 1

    if random_range:
        center = random.randint(absolute_min // 2, absolute_max // 2)
        spread = random.randint(100, 5000)

        min_value = max(absolute_min, center - spread)
        max_value = min(absolute_max, center + spread)
    else:
        min_value = absolute_min
        max_value = absolute_max

    memory = []

    for _ in range(size):
        value = random.randint(min_value, max_value)
        memory.append(value)

    print(f"Generated memory: {size} values")
    print(f"Data width: {data_width} bits")
    print(f"Signed: {signed}")
    print(f"Absolute value range: {absolute_min} to {absolute_max}")
    print(f"Generated value range: {min_value} to {max_value}\n")

    return memory


def reduction_tree_min_max(data):
    
    if len(data) == 0:
        raise ValueError("Memory is empty. Cannot find MIN and MAX.")

    min_level = data.copy()
    max_level = data.copy()

    level = 0

    print("START REDUCTION TREE")
    print(f"Level {level}: number of elements = {len(data)}")

    while len(min_level) > 1:
        next_min_level = []
        next_max_level = []

        for i in range(0, len(min_level), 2):
            if i + 1 >= len(min_level):
                next_min_level.append(min_level[i])
                next_max_level.append(max_level[i])
                continue

            a_min = min_level[i]
            b_min = min_level[i + 1]

            a_max = max_level[i]
            b_max = max_level[i + 1]

            if a_min < b_min:
                local_min = a_min
            else:
                local_min = b_min

            if a_max > b_max:
                local_max = a_max
            else:
                local_max = b_max

            next_min_level.append(local_min)
            next_max_level.append(local_max)

        min_level = next_min_level
        max_level = next_max_level

        level += 1
        print(f"Level {level}: number of elements = {len(min_level)}")

    final_min = min_level[0]
    final_max = max_level[0]

    return final_min, final_max


def verify_result(memory, result_min, result_max):
    reference_min = min(memory)
    reference_max = max(memory)

    print("\nRESULT")
    print("MIN =", result_min)
    print("MAX =", result_max)

    print("\nREFERENCE")
    print("Python min =", reference_min)
    print("Python max =", reference_max)

    if result_min == reference_min and result_max == reference_max:
        print("\nVerification: PASSED")
    else:
        print("\nVerification: FAILED")

memory = generate_memory(size=1024, data_width=16, signed=True, random_range=True)

result_min, result_max = reduction_tree_min_max(memory)

verify_result(memory, result_min, result_max)
