#!/bin/bash
# # HAVO
# PROJECT_DIR=/shared/ssd_16T/yl535/project/python/
# PROJECT_DIR=/data/home/luoy/project/python/
TASK=cls # md | tds | cls
MODEL_TYPE=( efficientnet ) # ( efficientnet resnet ) efficientnet | vit | resnet | swin | vgg | resnext | wideresnet | efficientnetv1 | convnext
LOSS_TYPE='bce' # mse | cos | kld | mae | gaussnll | bce 
LR=2e-5 # 5e-5 for rnflt with efficientnet | 2e-5 for rnflt with resnet | best 5e-5 for rnflt | 1e-4 for ilm
NUM_EPOCH=10
# BATCH_SIZE=16 # 16 is best
BATCH_SIZE=6 #( 10 12 14 16 18 20 ) best 6
STRETCH_RATIO=5 #( 0.5 1 2 5 10 26 ) # best 5
MODALITY_TYPE='color_fundus' # 'rnflt' | 'bscans' | 'oct_bscans' | 'slo_fundus' | 'oct_bscans_3d'
ATTRIBUTE_TYPE=( gender ) # race|gender|hispanic|maritalstatus|language

if [ ${MODALITY_TYPE} = 'rnflt' ]; then
	LR=5e-4 # 5e-5 for rnflt with efficientnet
	BATCH_SIZE=20 # 6 for rnflt with efficientnet | 20 for rnflt with resnet
elif [ ${MODALITY_TYPE} = 'oct_bscans' ]; then
	LR=5e-4 # 5e-5 for rnflt with efficientnet
	BATCH_SIZE=6 # 6 for rnflt with efficientnet | 20 for rnflt with resnet
elif [ ${MODALITY_TYPE} = 'oct_bscans_3d' ]; then
	LR=5e-4 # 5e-5 for rnflt with efficientnet
	BATCH_SIZE=6 # 6 for rnflt with efficientnet | 20 for rnflt with resnet
elif [ ${MODALITY_TYPE} = 'slo_fundus' ]; then
	LR=5e-5 # 5e-5 for rnflt with efficientnet
	BATCH_SIZE=6
elif [ ${MODALITY_TYPE} = 'color_fundus' ]; then
	LR=5e-5 # 5e-5 for rnflt with efficientnet
	BATCH_SIZE=6
else
	LR=5e-5 # 5e-5 for rnflt with efficientnet
	BATCH_SIZE=6
fi

LR=5e-4
BATCH_SIZE=6

# BATCH_SIZE=20 # ( 10 12 14 16 18 20 24 8 ) best is 6
# SPLIT_FILE=split7383.csv # split1064.csv split7383.csv # ( split7383.csv split5374.csv split4934.csv ) # ( split243.csv split533.csv split3376.csv split4546.csv split7026.csv split7578.csv split7906.csv split8049.csv split9361.csv split9471.csv )
SPLIT_FILE=split1064.csv # split1582.csv split1064.csv split2351.csv
SUBSET_NAME=test
NORMALIZATION_TYPE=fin # fin | bn | lbn
DATASET=grape
PROGRESS_TYPE=PLR3 # MD PLR2 PLR3
AUG_METHOD=m1
# PERF_FILE=${MODEL_TYPE}_${NORMALIZATION_TYPE}_${MODALITY_TYPE}_${ATTRIBUTE_TYPE}.csv
IMBALANCE_BETA=0.9999 # ( 0.99 0.999 0.9999 0.99999 ) # 0.9999
IMBALANCE_BETA=-1
TIME_WINDOW=20
FIN_MU=.01 # ( .001 .005 .02 .03 .04 .05 .1 .5 ) # .1 # ( .001 .005 .02 .03 .04 .05 .1 ) # 0.01 # ( 1 .1 .01 .001 .0001 .00001 0 ) # best .01
FIN_SIGMA=.5 # ( .1 .2 .3 .4 .5 .6 .7 .8 .9 1. 5. 10. ) # ( .1 .2 .3 .4 .5 .6 .7 .8 .9 ) # .5  # ( -1 -0.8 -0.6 -0.4 -0.2 -0.1 0 .1 0.2 ) # -0.6 -0.4 Best
FIN_SIGMA_COEF=0.5 # ( 0.5 1. 1.5 2. 3. 4. 5. 10. 20. 50. 100. ) # ( 0.5 1. 1.5 2. 3. 4. 5. 10. 20. 50. 100. ) # ( 1.1 1.2 1.3 1.4 1.5 2. 3. 4. 5. 10. 20. 50. 100. ) # ( 0.1 0.2 0.3 0.4 0.5 1 2 3 4 5 )
FIN_MOMENTUM=0.5 # ( .1 .2 .3 .4 .5 .6 .7 .8 .9 1 ) # 0.3 #  # best 0.2 for gender, .3 for race | 0.5 for 15K samples
DATASET_PROPORTION=1. # ( 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 )
# ${#FIN_SIGMA[@]}
for (( j=0; j<${#ATTRIBUTE_TYPE[@]}; j++ ));
do
PERF_FILE=${MODEL_TYPE}_${MODALITY_TYPE}_${ATTRIBUTE_TYPE[$j]}.csv
for (( i=0; i<5; i++ ));
do
python train_glaucoma_fair_proposed_allattr_withsplit_augmentation.py \
		--data_dir /data/home/shim/pyspace/fairness/dataset \
		--result_dir ./results_aug_grape/glaucoma_${PROGRESS_TYPE}_${AUG_METHOD}_${MODALITY_TYPE}_${ATTRIBUTE_TYPE[$j]}_fin/fullysup_${MODEL_TYPE}_${MODALITY_TYPE}_Task${TASK}_lr${LR}_bz${BATCH_SIZE}_${SUBSET_NAME} \
		--model_type ${MODEL_TYPE} \
        --dataset ${DATASET} \
		--image_size 224 \
		--loss_type ${LOSS_TYPE} \
		--lr ${LR} --weight-decay 0. --momentum 0.1 \
		--batch-size ${BATCH_SIZE} \
		--task ${TASK} \
		--epochs ${NUM_EPOCH} \
		--modality_types ${MODALITY_TYPE} \
		--imbalance_beta ${IMBALANCE_BETA} \
		--perf_file ${PERF_FILE} \
		--normalization_type ${NORMALIZATION_TYPE} \
		--time_window ${TIME_WINDOW} \
		--attribute_type ${ATTRIBUTE_TYPE[$j]} \
		--fin_mu ${FIN_MU} \
		--fin_sigma ${FIN_SIGMA} \
		--fin_momentum ${FIN_MOMENTUM} \
		--subset_name ${SUBSET_NAME} \
		--dataset_proportion ${DATASET_PROPORTION} \
		--split_file ${SPLIT_FILE} \
		--fin_sigma_coef 1. ${FIN_SIGMA_COEF}\
        --progression_type ${PROGRESS_TYPE} \
        --aug_method ${AUG_METHOD}
		# --seed 13 \
		# --data_dir ${PROJECT_DIR}/datasets/harvard/fairness_for_allyears/ \
		# --fin_sigma_coef 1 ${FIN_SIGMA_COEF[$i]} 1. \
		# --data_dir ${PROJECT_DIR}/datasets/harvard/glaucoma_ophthalmology_journal_9648/ \
		# --data_dir ${PROJECT_DIR}/datasets/harvard/glaucoma_lancet_journal_5612_3300/ \
done
done