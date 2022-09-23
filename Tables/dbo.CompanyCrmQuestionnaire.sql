CREATE TABLE [dbo].[CompanyCrmQuestionnaire]
(
[CompanyId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserDefined1] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef1] DEFAULT ((0)),
[UserDefined2] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef2] DEFAULT ((0)),
[UserDefined3] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef3] DEFAULT ((0)),
[UserDefined4] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef4] DEFAULT ((0)),
[UserDefined5] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef5] DEFAULT ((0)),
[UserDefined6] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef6] DEFAULT ((0)),
[UserDefined7] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef7] DEFAULT ((0)),
[UserDefined8] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef8] DEFAULT ((0)),
[UserDefined9] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef9] DEFAULT ((0)),
[UserDefined10] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef10] DEFAULT ((0)),
[UserDefined11] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef11] DEFAULT ((0)),
[UserDefined12] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef12] DEFAULT ((0)),
[UserDefined13] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef13] DEFAULT ((0)),
[UserDefined14] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef14] DEFAULT ((0)),
[UserDefined15] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef15] DEFAULT ((0)),
[UserDefined16] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef16] DEFAULT ((0)),
[UserDefined17] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef17] DEFAULT ((0)),
[UserDefined18] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef18] DEFAULT ((0)),
[UserDefined19] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef19] DEFAULT ((0)),
[UserDefined20] [tinyint] NOT NULL CONSTRAINT [df_questionnaire_userdef20] DEFAULT ((0)),
[Notes1] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_questionnaire_notes1] DEFAULT (''),
[Notes2] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_questionnaire_notes2] DEFAULT (''),
[Notes3] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_questionnaire_notes3] DEFAULT (''),
[Notes4] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_questionnaire_notes4] DEFAULT (''),
[RevenueMin] [money] NOT NULL CONSTRAINT [df_questionnaire_revenuemin] DEFAULT ((0)),
[RevenueMax] [money] NOT NULL CONSTRAINT [df_questionnaire_revenuemax] DEFAULT ((0)),
[LoadsMin] [int] NOT NULL CONSTRAINT [df_questionnaire_loadsmin] DEFAULT ((0)),
[LoadsMax] [int] NOT NULL CONSTRAINT [df_questionnaire_loadsmax] DEFAULT ((0)),
[OwnerType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyCr__Owner__3B8C14E4] DEFAULT ('CMP')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyCrmQuestionnaire] ADD CONSTRAINT [pk_owner_company_crmquestionnaire] PRIMARY KEY CLUSTERED ([OwnerType], [CompanyId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyCrmQuestionnaire] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyCrmQuestionnaire] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CompanyCrmQuestionnaire] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyCrmQuestionnaire] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyCrmQuestionnaire] TO [public]
GO
