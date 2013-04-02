/*
 * SevenCBoxSession.cpp
 *
 *  Created on: 2012-11-5
 *      Author: zhangdl
 */
#include "clientlib/SevenCBoxSession.h"
#include "clientlib/SevenCBoxClientConfig.h"

SevenCBoxSession::~SevenCBoxSession() {
	// TODO Auto-generated destructor stub
}
/**
 * 获取会话用户ID
 */
string SevenCBoxSession::GetUserId(){
	return this->sUserId;
}
/**
 * 获取会话用户名
 */
string SevenCBoxSession::GetUserAccountName(){
    
	return this->sUserName;
    
}
/**
 * 获取客户端标记
 */
string SevenCBoxSession::GetClientTag(){
	return ClientConfig::CLIENT_TAG;
}
/**
 * 获取用户令牌
 */
string SevenCBoxSession::GetUserToken(){
	return this->sUserToken;
}


