import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import csv
from sklearn.preprocessing import MinMaxScaler
from keras import Sequential
from keras.layers import LSTM, Dense
from keras.models import load_model
from sklearn.neighbors import LocalOutlierFactor


def train(TRAIN_PATH,name):
    try:
        if name:
            model_name = model_train(TRAIN_PATH, name)
            print('模型训练完成!')
            return model_name
        else:
            print('请输入模型名称')
    except Exception as e:
        print(str(e))

def model_train(TRAINDATA, model_name):
    data = pd.read_csv(TRAINDATA, header=0, index_col=0)
    data = series_to_supervised(data.values, data.columns, 1, 1)  # data.values是数据值不包括列标签，data.columns是数据的标签
    # 数据归一化
    scaler = MinMaxScaler(feature_range=(0, 1))
    data = scaler.fit_transform(data)
    # 将数据集切分
    nSample, ncol = data.shape
    cut = (int)(0.8*nSample)
    train = data[:cut, :]
    test = data[cut:, :]
    train_x, train_y, t1 = segment(train)
    test_x, test_y, t2 = segment(test)
    if t1 and t2:
        train_x = train_x.reshape((train_x.shape[0], 1, train_x.shape[1]))
        test_x = test_x.reshape((test_x.shape[0], 1, test_x.shape[1]))
        model = Sequential()
        model.add(LSTM(50, input_shape=(train_x.shape[1], train_x.shape[2])))
        model.add(Dense(1))
        model.compile(loss='mae', optimizer='adam')
        sensor = model.fit(train_x, train_y, epochs=50, batch_size=72, validation_data=(test_x, test_y))
        model_name1 = './Model/' + model_name + '.h5'
        model.save(model_name1)
        return model_name1
    else:
        print('测点序号超出范围')

def series_to_supervised(data, columns, n_in=1, n_out=1, dropnan=True):
    n_vars = 1 if type(data) is list else data.shape[1]  # 赋值总的列数
    df = pd.DataFrame(data)
    cols, names = list(), list()
    for i in range(n_in, 0, -1):  # 最后的参数-1的意思是倒着取数 通常为默认为1，正着取数，取不到上值，上值为开区间
        cols.append(df.shift(i))  # 将数据整体下移一行
        names += [('%s%d(t-%d)' % (columns[j], j + 1, i)) for j in range(n_vars)]  # 给names赋值
    for i in range(0, n_out):
        cols.append(df.shift(-i))
        if i == 0:
            names += [('%s%d(t)' % (columns[j], j + 1)) for j in range(n_vars)]
        else:
            names += [('%s%d(t+%d)' % (columns[j], j + 1, i)) for j in range(n_vars)]
    # put it all together
    agg = pd.concat(cols, axis=1)
    agg.columns = names
    # drop rows with NaN values
    if dropnan:
        clean_agg = agg.dropna()
    return clean_agg

def segment(dataset):
    '''切分函数'''
    x = []
    y = []
    i = 1
    x, y, t = segment_dataset(dataset, i)
    return x, y, True

def segment_dataset(dataset, column):
    '''切分函数的子函数'''
    x = []
    y = []
    a, b = np.split(dataset, [column - 1], axis=1)
    b, c = np.split(b, [1], axis=1)
    x = np.concatenate([a, c], axis=1)
    y = b
    return x, y, True

def predict(TEST_PATH,model_name,sensor):
    origin_data, predict_data = model_predict(TEST_PATH, model_name)
    origin_data = origin_data
    predict_data = predict_data
    lstm_show(origin_data, predict_data, sensor)

def model_predict(PREDICTDATA, model_name):
    '''
    属于需要进行预测的数据,对所选的测点进行预测
    :param PREDICTDATA: 进行预测的数据集的路径
    :param model_name:模型名称
    :return:原始数据和预测数据
    '''
    data = pd.read_csv(PREDICTDATA, header=0, index_col=0)
    data = series_to_supervised(data.values, data.columns, 1, 1)
    # 数据归一化
    scaler = MinMaxScaler(feature_range=(0, 1))
    data = scaler.fit_transform(data)
    input_x, origin_y, t = segment(data)
    input_x = input_x.reshape((input_x.shape[0], 1, input_x.shape[1]))
    model = Sequential()
    model = load_model(model_name)
    predict_y = model.predict(input_x)
    return origin_y, predict_y

def lstm_show(origin_y,predict_y,sensor):
    '''
    可视化LSTM网络的预测结果
    :param origin_y: 原始数据
    :param predict_y: 预测的数据
    :return:
    '''
    plt.plot(predict_y, 'red',alpha=0.6, label='Predicted result')
    plt.plot(origin_y, 'royalblue',linestyle='--',alpha=1, label='Real data')
    plt.title('Data prediction based on LSTM: NO.%s sensor'%(sensor), fontsize=11)
    plt.ylabel('NO.%s sensor data'%(sensor))
    plt.xlabel('time')
    plt.legend()
    plt.show()

if __name__ == '__main__':
    model_name = train("../../Data/Mytrain.csv","123")
    predict("../../Data/Mypredict.csv",model_name,1)