import random
def gen_data_mem():
    file = open('add8_data_mem.txt','w');
    data_list = [];
    random_num_list = [];
    for i in range(512):
        if (i < 8):
            rand_num = random.randint(0,5000)
            random_num_list.append(rand_num)
            data_list.append("{0:016b}".format(rand_num))
        else:
            data_list.append("0000000000000000")
    print 'Generated 8 numbers are', random_num_list
    print 'The sum of the 8 numbers =', sum(random_num_list)
    for item in data_list:
    	file.write(item)
    	file.write('\n')
    file.close()
    print 'Data mem is generated successfully'

if __name__ == '__main__':
    gen_data_mem()
