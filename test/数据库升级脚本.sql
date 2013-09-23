insert into t_space_info(userloginId,space_size,space_inuse) select f.userloginId,f.totalsize,f.usedsize as userloginId from t_pm_userlogin f where f.userloginId not in (select s.userloginId from t_space_info s);



update t_fm_fileinfo t join t_space_info s set t.space_id = s.space_id where s.userloginId = t.file_owner;


update t_fm_fileinfo t set file_iszone = 0 where file_istrash = 1 or file_ispartaketrash = 1;

update t_fm_fileinfo t set file_iszone = 2 where file_ispartake = 1;


8/21 更新  ndsDB
insert into t_space_info(userloginId,space_size,space_type,space_comment) 
select f.userloginId,1073741824,2,'家庭空间' as userloginId from t_space_info f 
where f.userloginId not in (select s.userloginId from t_space_info s where s.space_type = 2);

update t_space_info set space_size = 1073741824 where space_type = 2

8/29 更新 ndsDB


ALTER TABLE t_package add  `meal_id`  int(11) default NULL  COMMENT '套餐ID';
ALTER TABLE t_meal_info add  `meal_cycle` int(11) default NULL COMMENT '使用周期（单位月）';
ALTER TABLE t_user_meal add  `order_id` bigint(20) default NULL COMMENT '订单id';
alter table t_package add constraint package_meal_fk Foreign Key (meal_id)
References t_meal_info (meal_id);


delete from t_package;
delete from t_meal_info;
LOCK TABLES `t_meal_info` WRITE;
/*!40000 ALTER TABLE `t_meal_info` DISABLE KEYS */;
INSERT INTO `t_meal_info` VALUES (1,1,'免费套餐',1073741824,0,0,0);
INSERT INTO `t_meal_info` VALUES (2,2,'家庭空间套餐1',53687091200,150,0,12);
INSERT INTO `t_meal_info` VALUES (3,3,'家庭空间套餐2',107374182400,300,0,12);
INSERT INTO `t_meal_info` VALUES (4,4,'家庭空间套餐3',214748364800,600,0,12);
/*!40000 ALTER TABLE `t_meal_info` ENABLE KEYS */;
UNLOCK TABLES;


LOCK TABLES `t_package` WRITE;
/*!40000 ALTER TABLE `t_package` DISABLE KEYS */;
INSERT INTO `t_package` VALUES (1,1,0,10,524288000,30,21474836480,100,7,0);
INSERT INTO `t_package` VALUES (2,2,0,10,1263465465,10,10,10,12,10);
INSERT INTO `t_package` VALUES (3,3,0,10,241255645645,10,10,10,12,15);
INSERT INTO `t_package` VALUES (4,4,0,10,45754654654,10,10,10,12,20);
/*!40000 ALTER TABLE `t_package` ENABLE KEYS */;
UNLOCK TABLES;


CREATE TABLE `t_user_order` (
  `order_id` bigint(20) NOT NULL auto_increment,
  `order_no` varchar(50) NOT NULL,
  `order_name` varchar(100) NOT NULL,
  `order_settime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `order_paytime` timestamp NULL default NULL,
  `order_desc` varchar(255) NOT NULL,
  `order_account` varchar(32) NOT NULL,
  `order_systype` int(4) NOT NULL,
  `order_mealno` varchar(10) NOT NULL,
  `order_enddate` date NOT NULL,
  `order_pluschild` int(11) NOT NULL default '0',
  `order_isconvert` int(1) NOT NULL,
  `order_convertprice` decimal(8,2) NOT NULL,
  `order_price` decimal(8,2) NOT NULL,
  `order_status` int(4) NOT NULL,
  `order_alipayno` varchar(50) default NULL,
  PRIMARY KEY  (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;ndsDB



insert into t_friends_group(userloginid,group_name,group_type,add_date) 
select f.userloginId,'我的家庭',2,now() from t_friends_group f 
where f.userloginId not in (select s.userloginid from t_friends_group s where s.group_type = 2);

