-- ============================================================
-- TimeDiary（“时光日记”微信小程序）数据库 · DDL（Data Definition Language / 数据定义语言）
-- 作用：只建“骨架”——表、字段、主键、唯一键、外键、索引
-- 数据库：timediary          版本：MySQL 5.0
-- 结构规模：15 张表 · 144 字段 · 0 序列 · 19 外键 · 18 二级索引
-- 整理日期：2026-10-29
-- 说明：字段类型统一用 varchar(32) 作主键；JSON 类字段以 text 存储，
--       若数据库为 MySQL 5.7+ 可自行改为 json 类型（不影响其他语句）。
-- ============================================================


-- ============================================================
-- 0. 清理旧表（DROP TABLE）
-- ============================================================

-- 重建时先关闭外键检查，避免父表被子表外键引用而无法删除
set foreign_key_checks = 0;

drop table if exists AIReports;

drop table if exists Badges;

drop table if exists Categories;

drop table if exists CheckIns;

drop table if exists CountdownEvents;

drop table if exists Diaries;

drop table if exists DiaryMedia;

drop table if exists FeedLogs;

drop table if exists FoodItems;

drop table if exists Notifications;

drop table if exists Pets;

drop table if exists RandomDecisions;

drop table if exists TimeCapsules;

drop table if exists UserBadges;

drop table if exists Users;

-- 建表前恢复外键检查
set foreign_key_checks = 1;


-- ============================================================
-- 1. 表定义（CREATE TABLE）
-- ============================================================

-- AI 总结报告表（周报/月报/年度报告的生成留档，含情绪分布）
create table AIReports
(
   report_id            varchar(32) not null,
   user_id              varchar(32) not null,
   report_type          varchar(10) not null,
   period_start         date not null,
   period_end           date not null,
   diary_count          int not null,
   content              text,
   emotion_stats        text,
   model_name           varchar(50),
   created_at           datetime not null
);

-- 徽章表（徽章字典，定义解锁条件类型与阈值）
create table Badges
(
   badge_id             varchar(32) not null,
   name                 varchar(50) not null,
   description          varchar(255),
   icon_url             varchar(255),
   condition_type       varchar(30) not null,
   condition_value      int not null,
   badge_level          int not null,
   sort_order           int not null
);

-- 日记分类表（用户自定义分类，如工作/旅行/心情）
create table Categories
(
   category_id          varchar(32) not null,
   user_id              varchar(32) not null,
   name                 varchar(50) not null,
   icon                 varchar(50),
   color                varchar(10),
   sort_order           int not null,
   is_default           bool not null,
   diary_count          int not null,
   created_at           datetime not null
);

-- 打卡记录表（每日打卡留痕与连续天数统计）
create table CheckIns
(
   checkin_id           varchar(32) not null,
   user_id              varchar(32) not null,
   diary_id             varchar(32),
   checkin_date         date not null,
   continuous_days      int not null,
   is_makeup            bool not null,
   reward_exp           int not null,
   created_at           datetime not null
);

-- 倒计时事件表（生日/考试/旅行等重要事件的倒计时）
create table CountdownEvents
(
   event_id             varchar(32) not null,
   user_id              varchar(32) not null,
   title                varchar(50) not null,
   event_type           varchar(20) not null,
   target_date          date not null,
   repeat_type          varchar(10) not null,
   remind_days          int not null,
   theme_color          varchar(10),
   is_top               bool not null,
   status               int not null,
   created_at           datetime not null
);

-- 日记表（系统主表，日记正文加密存储，支持草稿与收藏）
create table Diaries
(
   diary_id             varchar(32) not null,
   user_id              varchar(32) not null,
   category_id          varchar(32),
   title                varchar(100),
   content              text not null,
   content_iv           varchar(64),
   mood                 varchar(20),
   weather              varchar(20),
   location             varchar(100),
   diary_date           date not null,
   word_count           int not null,
   is_favorite          bool not null,
   is_draft             bool not null,
   status               int not null,
   created_at           datetime not null,
   updated_at           datetime
);

-- 日记媒体表（一篇日记的图片/视频/语音附件）
create table DiaryMedia
(
   media_id             varchar(32) not null,
   diary_id             varchar(32) not null,
   user_id              varchar(32) not null,
   file_id              varchar(255) not null,
   media_type           varchar(20) not null,
   file_size            int,
   duration             int,
   cover_url            varchar(255),
   sort_order           int not null,
   created_at           datetime not null
);

-- 喂养记录表（写日记兑换食物、主动投喂产生的流水）
create table FeedLogs
(
   feed_id              varchar(32) not null,
   pet_id               varchar(32) not null,
   user_id              varchar(32) not null,
   diary_id             varchar(32),
   food_id              varchar(32),
   feed_type            varchar(20) not null,
   exp_gain             int not null,
   hunger_after         int not null,
   feed_time            datetime not null
);

-- 食物道具表（食物字典，含经验加成、饱腹值与价格）
create table FoodItems
(
   food_id              varchar(32) not null,
   name                 varchar(30) not null,
   icon_url             varchar(255),
   exp_value            int not null,
   hunger_value         int not null,
   price                int not null,
   is_active            bool not null
);

-- 消息推送表（打卡提醒、胶囊到期、徽章解锁的推送流水）
create table Notifications
(
   notification_id      varchar(32) not null,
   user_id              varchar(32) not null,
   notify_type          varchar(20) not null,
   related_id           varchar(32),
   content              varchar(255) not null,
   channel              varchar(20) not null,
   send_time            datetime,
   status               int not null
);

-- 虚拟宠物表（一个用户一只宠物，随写作行为成长）
create table Pets
(
   pet_id               varchar(32) not null,
   user_id              varchar(32) not null,
   pet_name             varchar(30) not null,
   pet_type             varchar(20) not null,
   skin_id              varchar(32),
   level                int not null,
   exp                  int not null,
   hunger               int not null,
   intimacy             int not null,
   status               int not null,
   last_feed_time       datetime,
   created_at           datetime not null
);

-- 随机决策表（“今天吃什么”类抽签记录）
create table RandomDecisions
(
   decision_id          varchar(32) not null,
   user_id              varchar(32) not null,
   question             varchar(100) not null,
   options              text not null,
   result_option        varchar(50) not null,
   scene                varchar(20),
   is_favorite          bool not null,
   decide_time          datetime not null
);

-- 时间胶囊表（写给未来的信，到期由定时任务推送）
create table TimeCapsules
(
   capsule_id           varchar(32) not null,
   user_id              varchar(32) not null,
   title                varchar(100),
   content              text not null,
   media_list           text,
   open_time            datetime not null,
   status               int not null,
   is_notified          bool not null,
   created_at           datetime not null
);

-- 用户徽章表（用户与徽章的多对多桥接表，并记录进度）
create table UserBadges
(
   user_badge_id        varchar(32) not null,
   user_id              varchar(32) not null,
   badge_id             varchar(32) not null,
   progress             int not null,
   is_unlocked          bool not null,
   unlock_time          datetime
);

-- 用户表（微信身份、隐私等级与提醒设置，全库的根表）
create table Users
(
   user_id              varchar(32) not null,
   openid               varchar(64) not null,
   unionid              varchar(64),
   nickname             varchar(50),
   avatar_url           varchar(255),
   gender               int,
   birthday             date,
   privacy_level        int not null,
   remind_time          varchar(5),
   notify_enabled       bool not null,
   register_time        datetime not null,
   last_login_time      datetime,
   status               int not null
);


-- ============================================================
-- 2. 主键 / 唯一键
-- ============================================================

alter table AIReports add constraint pk_aireports primary key (report_id);

alter table Badges add constraint pk_badges primary key (badge_id);

alter table Categories add constraint pk_categories primary key (category_id);

alter table CheckIns add constraint pk_checkins primary key (checkin_id);

alter table CountdownEvents add constraint pk_countdownevents primary key (event_id);

alter table Diaries add constraint pk_diaries primary key (diary_id);

alter table DiaryMedia add constraint pk_diarymedia primary key (media_id);

alter table FeedLogs add constraint pk_feedlogs primary key (feed_id);

alter table FoodItems add constraint pk_fooditems primary key (food_id);

alter table Notifications add constraint pk_notifications primary key (notification_id);

alter table Pets add constraint pk_pets primary key (pet_id);

alter table RandomDecisions add constraint pk_randomdecisions primary key (decision_id);

alter table TimeCapsules add constraint pk_timecapsules primary key (capsule_id);

alter table UserBadges add constraint pk_userbadges primary key (user_badge_id);

alter table Users add constraint pk_users primary key (user_id);


-- ============================================================
-- 3. 外键（FOREIGN KEY）
-- 说明：约束名全库唯一；全部采用 restrict，删除父表数据前须先处理子表。
-- ============================================================

alter table AIReports add constraint FK_Summarize foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table Categories add constraint FK_Defines foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table CheckIns add constraint FK_ChecksIn foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table CheckIns add constraint FK_Triggers foreign key (diary_id)
      references Diaries (diary_id) on delete restrict on update restrict;

alter table CountdownEvents add constraint FK_Sets foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table Diaries add constraint FK_Writes foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table Diaries add constraint FK_BelongsTo foreign key (category_id)
      references Categories (category_id) on delete restrict on update restrict;

alter table DiaryMedia add constraint FK_Contains foreign key (diary_id)
      references Diaries (diary_id) on delete restrict on update restrict;

alter table DiaryMedia add constraint FK_Uploads foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table FeedLogs add constraint FK_Generates foreign key (pet_id)
      references Pets (pet_id) on delete restrict on update restrict;

alter table FeedLogs add constraint FK_Feeds foreign key (food_id)
      references FoodItems (food_id) on delete restrict on update restrict;

alter table FeedLogs add constraint FK_Sources foreign key (diary_id)
      references Diaries (diary_id) on delete restrict on update restrict;

alter table FeedLogs add constraint FK_Records foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table Notifications add constraint FK_Receives foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table Pets add constraint FK_Owns foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table RandomDecisions add constraint FK_Draws foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table TimeCapsules add constraint FK_Seals foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table UserBadges add constraint FK_Earns foreign key (user_id)
      references Users (user_id) on delete restrict on update restrict;

alter table UserBadges add constraint FK_Award foreign key (badge_id)
      references Badges (badge_id) on delete restrict on update restrict;


-- ============================================================
-- 4. 索引（二级索引）
-- 说明：外键列 MySQL 会自动建索引，下列为按查询需求补的复合 / 唯一索引。
--       若复合索引已以外键列开头，可在建完后删除自动生成的单列索引。
-- ============================================================

-- 微信 openid 唯一，登录时按此定位用户
create unique index uq_users_openid on Users (openid);

-- 按用户查分类列表（含排序）
create index idx_categories_user on Categories (user_id, sort_order);

-- 首页时间轴：按用户按日期倒序
create index idx_diaries_user_date on Diaries (user_id, diary_date);

-- 我的收藏列表
create index idx_diaries_favorite on Diaries (user_id, is_favorite, diary_date);

-- 按分类筛选日记
create index idx_diaries_category on Diaries (user_id, category_id, diary_date);

-- 日记详情页附件按顺序展示
create index idx_media_diary on DiaryMedia (diary_id, sort_order);

-- 一天最多一次打卡（业务硬约束）
create unique index uq_checkins_user_date on CheckIns (user_id, checkin_date);

-- 一人一宠（1:1 的落地方式）
create unique index uq_pets_user on Pets (user_id);

-- 宠物喂养历史曲线
create index idx_feedlogs_pet on FeedLogs (pet_id, feed_time);

-- 同一篇日记只能领一次奖励
create unique index uq_feedlogs_user_diary on FeedLogs (user_id, diary_id);

-- 倒计时按剩余天数排序
create index idx_countdown_user_date on CountdownEvents (user_id, target_date);

-- 定时触发器扫描到期胶囊
create index idx_capsules_open_time on TimeCapsules (open_time);

-- 报告列表按类型按时序
create index idx_ai_reports_user on AIReports (user_id, report_type, created_at);

-- 决策历史列表
create index idx_decisions_user on RandomDecisions (user_id, decide_time);

-- 推送流水查询与失败重试
create index idx_notifications_user on Notifications (user_id, notify_type, send_time);

-- 同一徽章只授予一次
create unique index uq_userbadges_user_badge on UserBadges (user_id, badge_id);

-- 徽章名称唯一
create unique index uq_badges_name on Badges (name);

-- 食物名称唯一
create unique index uq_fooditems_name on FoodItems (name);


-- ============================================================
-- 5. 表 / 字段注释
-- ============================================================

alter table AIReports comment 'AI 总结报告表：周报/月报/年度报告的生成留档，含情绪分布';
alter table AIReports modify column report_id varchar(32) not null comment '报告ID（主键）';
alter table AIReports modify column user_id varchar(32) not null comment '所属用户ID';
alter table AIReports modify column report_type varchar(10) not null comment '报告类型：week/month/year';
alter table AIReports modify column period_start date not null comment '统计区间开始日期';
alter table AIReports modify column period_end date not null comment '统计区间结束日期';
alter table AIReports modify column diary_count int not null comment '覆盖日记篇数';
alter table AIReports modify column content text comment 'AI 生成的总结正文';
alter table AIReports modify column emotion_stats text comment '情绪分布（JSON 文本）';
alter table AIReports modify column model_name varchar(50) comment '调用的模型名称';
alter table AIReports modify column created_at datetime not null comment '生成时间';

alter table Badges comment '徽章表：徽章字典，定义解锁条件类型与阈值';
alter table Badges modify column badge_id varchar(32) not null comment '徽章ID（主键）';
alter table Badges modify column name varchar(50) not null comment '徽章名称';
alter table Badges modify column description varchar(255) comment '获得说明文案';
alter table Badges modify column icon_url varchar(255) comment '徽章图标地址';
alter table Badges modify column condition_type varchar(30) not null comment '条件类型：continuous_days/diary_count/word_count/favorite_count';
alter table Badges modify column condition_value int not null comment '条件阈值';
alter table Badges modify column badge_level int not null comment '徽章等级：1铜/2银/3金';
alter table Badges modify column sort_order int not null comment '展示排序';

alter table Categories comment '日记分类表：用户自定义分类，如工作/旅行/心情';
alter table Categories modify column category_id varchar(32) not null comment '分类ID（主键）';
alter table Categories modify column user_id varchar(32) not null comment '所属用户ID';
alter table Categories modify column name varchar(50) not null comment '分类名称';
alter table Categories modify column icon varchar(50) comment '分类图标';
alter table Categories modify column color varchar(10) comment '主题色（#RRGGBB）';
alter table Categories modify column sort_order int not null comment '排序号';
alter table Categories modify column is_default bool not null comment '是否默认分类：每用户仅一条为真';
alter table Categories modify column diary_count int not null comment '该分类下日记数量（冗余统计）';
alter table Categories modify column created_at datetime not null comment '创建时间';

alter table CheckIns comment '打卡记录表：每日打卡留痕与连续天数统计';
alter table CheckIns modify column checkin_id varchar(32) not null comment '打卡ID（主键）';
alter table CheckIns modify column user_id varchar(32) not null comment '打卡用户ID';
alter table CheckIns modify column diary_id varchar(32) comment '触发的日记ID（补卡时为空）';
alter table CheckIns modify column checkin_date date not null comment '打卡日期';
alter table CheckIns modify column continuous_days int not null comment '截至当日的连续打卡天数';
alter table CheckIns modify column is_makeup bool not null comment '是否补卡';
alter table CheckIns modify column reward_exp int not null comment '本次奖励经验值';
alter table CheckIns modify column created_at datetime not null comment '打卡时间';

alter table CountdownEvents comment '倒计时事件表：生日/考试/旅行等重要事件的倒计时';
alter table CountdownEvents modify column event_id varchar(32) not null comment '事件ID（主键）';
alter table CountdownEvents modify column user_id varchar(32) not null comment '所属用户ID';
alter table CountdownEvents modify column title varchar(50) not null comment '事件名称';
alter table CountdownEvents modify column event_type varchar(20) not null comment '事件类型：birthday/exam/travel/custom';
alter table CountdownEvents modify column target_date date not null comment '目标日期';
alter table CountdownEvents modify column repeat_type varchar(10) not null comment '重复方式：none/yearly';
alter table CountdownEvents modify column remind_days int not null comment '提前提醒天数';
alter table CountdownEvents modify column theme_color varchar(10) comment '卡片主题色';
alter table CountdownEvents modify column is_top bool not null comment '是否置顶';
alter table CountdownEvents modify column status int not null comment '状态：1进行中/2已结束';
alter table CountdownEvents modify column created_at datetime not null comment '创建时间';

alter table Diaries comment '日记表：系统主表，日记正文加密存储，支持草稿与收藏';
alter table Diaries modify column diary_id varchar(32) not null comment '日记ID（主键）';
alter table Diaries modify column user_id varchar(32) not null comment '作者用户ID';
alter table Diaries modify column category_id varchar(32) comment '所属分类ID（为空归入默认分类）';
alter table Diaries modify column title varchar(100) comment '日记标题';
alter table Diaries modify column content text not null comment '正文（AES 加密后的密文）';
alter table Diaries modify column content_iv varchar(64) comment '加密初始化向量';
alter table Diaries modify column mood varchar(20) comment '心情';
alter table Diaries modify column weather varchar(20) comment '天气';
alter table Diaries modify column location varchar(100) comment '地点文本';
alter table Diaries modify column diary_date date not null comment '日记归属日期';
alter table Diaries modify column word_count int not null comment '字数';
alter table Diaries modify column is_favorite bool not null comment '是否收藏';
alter table Diaries modify column is_draft bool not null comment '是否草稿（草稿不计入打卡与统计）';
alter table Diaries modify column status int not null comment '状态：1正常/0已删除';
alter table Diaries modify column created_at datetime not null comment '创建时间';
alter table Diaries modify column updated_at datetime comment '更新时间';

alter table DiaryMedia comment '日记媒体表：一篇日记的图片/视频/语音附件';
alter table DiaryMedia modify column media_id varchar(32) not null comment '媒体ID（主键）';
alter table DiaryMedia modify column diary_id varchar(32) not null comment '所属日记ID';
alter table DiaryMedia modify column user_id varchar(32) not null comment '所属用户ID（冗余，便于越权校验）';
alter table DiaryMedia modify column file_id varchar(255) not null comment '云存储文件标识';
alter table DiaryMedia modify column media_type varchar(20) not null comment '媒体类型：image/video/audio';
alter table DiaryMedia modify column file_size int comment '文件大小（字节）';
alter table DiaryMedia modify column duration int comment '音视频时长（秒）';
alter table DiaryMedia modify column cover_url varchar(255) comment '视频封面地址';
alter table DiaryMedia modify column sort_order int not null comment '展示顺序';
alter table DiaryMedia modify column created_at datetime not null comment '创建时间';

alter table FeedLogs comment '喂养记录表：写日记兑换食物、主动投喂产生的流水';
alter table FeedLogs modify column feed_id varchar(32) not null comment '喂养ID（主键）';
alter table FeedLogs modify column pet_id varchar(32) not null comment '被喂养的宠物ID';
alter table FeedLogs modify column user_id varchar(32) not null comment '操作人用户ID';
alter table FeedLogs modify column diary_id varchar(32) comment '来源日记ID（主动投喂时为空）';
alter table FeedLogs modify column food_id varchar(32) comment '投喂的食物ID（写日记奖励时为空）';
alter table FeedLogs modify column feed_type varchar(20) not null comment '喂养方式：write_diary/manual/reward';
alter table FeedLogs modify column exp_gain int not null comment '本次获得经验';
alter table FeedLogs modify column hunger_after int not null comment '喂养后饥饿值';
alter table FeedLogs modify column feed_time datetime not null comment '喂养时间';

alter table FoodItems comment '食物道具表：食物字典，含经验加成、饱腹值与价格';
alter table FoodItems modify column food_id varchar(32) not null comment '食物ID（主键）';
alter table FoodItems modify column name varchar(30) not null comment '食物名称';
alter table FoodItems modify column icon_url varchar(255) comment '食物图标地址';
alter table FoodItems modify column exp_value int not null comment '经验加成';
alter table FoodItems modify column hunger_value int not null comment '饱腹值';
alter table FoodItems modify column price int not null comment '所需时光币（0 表示写日记免费获得）';
alter table FoodItems modify column is_active bool not null comment '是否上架';

alter table Notifications comment '消息推送表：打卡提醒、胶囊到期、徽章解锁的推送流水';
alter table Notifications modify column notification_id varchar(32) not null comment '推送ID（主键）';
alter table Notifications modify column user_id varchar(32) not null comment '接收人用户ID';
alter table Notifications modify column notify_type varchar(20) not null comment '推送类型：checkin_remind/capsule_due/badge_unlock';
alter table Notifications modify column related_id varchar(32) comment '关联业务ID（多态引用，不建外键）';
alter table Notifications modify column content varchar(255) not null comment '推送内容';
alter table Notifications modify column channel varchar(20) not null comment '推送渠道：subscribe';
alter table Notifications modify column send_time datetime comment '实际发送时间';
alter table Notifications modify column status int not null comment '状态：0待发/1成功/2失败';

alter table Pets comment '虚拟宠物表：一个用户一只宠物，随写作行为成长';
alter table Pets modify column pet_id varchar(32) not null comment '宠物ID（主键）';
alter table Pets modify column user_id varchar(32) not null comment '主人用户ID（唯一，实现一人一宠）';
alter table Pets modify column pet_name varchar(30) not null comment '宠物名称';
alter table Pets modify column pet_type varchar(20) not null comment '宠物类型：猫/狗等';
alter table Pets modify column skin_id varchar(32) comment '形象皮肤ID';
alter table Pets modify column level int not null comment '等级';
alter table Pets modify column exp int not null comment '经验值';
alter table Pets modify column hunger int not null comment '饥饿值（0-100）';
alter table Pets modify column intimacy int not null comment '亲密度（0-100）';
alter table Pets modify column status int not null comment '状态：1正常/2饥饿/3想你';
alter table Pets modify column last_feed_time datetime comment '上次喂养时间';
alter table Pets modify column created_at datetime not null comment '领养时间';

alter table RandomDecisions comment '随机决策表：“今天吃什么”类抽签记录';
alter table RandomDecisions modify column decision_id varchar(32) not null comment '决策ID（主键）';
alter table RandomDecisions modify column user_id varchar(32) not null comment '所属用户ID';
alter table RandomDecisions modify column question varchar(100) not null comment '问题文本';
alter table RandomDecisions modify column options text not null comment '候选选项（JSON 数组文本）';
alter table RandomDecisions modify column result_option varchar(50) not null comment '抽中结果';
alter table RandomDecisions modify column scene varchar(20) comment '使用场景：food/travel/entertainment/custom';
alter table RandomDecisions modify column is_favorite bool not null comment '是否收藏为模板';
alter table RandomDecisions modify column decide_time datetime not null comment '决策时间';

alter table TimeCapsules comment '时间胶囊表：写给未来的信，到期由定时任务推送';
alter table TimeCapsules modify column capsule_id varchar(32) not null comment '胶囊ID（主键）';
alter table TimeCapsules modify column user_id varchar(32) not null comment '写信人用户ID';
alter table TimeCapsules modify column title varchar(100) comment '胶囊标题';
alter table TimeCapsules modify column content text not null comment '信件正文（AES 加密后的密文）';
alter table TimeCapsules modify column media_list text comment '图片/语音文件标识列表（JSON 文本）';
alter table TimeCapsules modify column open_time datetime not null comment '开启时间';
alter table TimeCapsules modify column status int not null comment '状态：1未开启/2已开启';
alter table TimeCapsules modify column is_notified bool not null comment '到期是否已推送';
alter table TimeCapsules modify column created_at datetime not null comment '创建时间';

alter table UserBadges comment '用户徽章表：用户与徽章的多对多桥接表，并记录进度';
alter table UserBadges modify column user_badge_id varchar(32) not null comment '记录ID（主键）';
alter table UserBadges modify column user_id varchar(32) not null comment '获得人用户ID';
alter table UserBadges modify column badge_id varchar(32) not null comment '徽章ID';
alter table UserBadges modify column progress int not null comment '当前进度';
alter table UserBadges modify column is_unlocked bool not null comment '是否已解锁';
alter table UserBadges modify column unlock_time datetime comment '解锁时间';

alter table Users comment '用户表：微信身份、隐私等级与提醒设置，全库的根表';
alter table Users modify column user_id varchar(32) not null comment '用户ID（主键）';
alter table Users modify column openid varchar(64) not null comment '微信 openid，全库唯一';
alter table Users modify column unionid varchar(64) comment '微信 unionid';
alter table Users modify column nickname varchar(50) comment '昵称';
alter table Users modify column avatar_url varchar(255) comment '头像地址';
alter table Users modify column gender int comment '性别：0未知/1男/2女';
alter table Users modify column birthday date comment '生日';
alter table Users modify column privacy_level int not null comment '隐私等级：0仅本地/1云端加密/2云端明文';
alter table Users modify column remind_time varchar(5) comment '打卡提醒时刻，如 21:30';
alter table Users modify column notify_enabled bool not null comment '是否接收订阅消息';
alter table Users modify column register_time datetime not null comment '注册时间';
alter table Users modify column last_login_time datetime comment '最近登录时间';
alter table Users modify column status int not null comment '账号状态：1正常/0已注销';


-- ============================================================
-- DDL 结束
-- ============================================================
