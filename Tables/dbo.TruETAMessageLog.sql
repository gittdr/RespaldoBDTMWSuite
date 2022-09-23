CREATE TABLE [dbo].[TruETAMessageLog]
(
[teml_id] [int] NOT NULL IDENTITY(1, 1),
[teml_customerid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[teml_description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[teml_status] [int] NULL,
[teml_tripid] [int] NULL,
[teml_alk_tripid] [int] NULL,
[teml_reqstart] [datetime] NULL,
[teml_reqend] [datetime] NULL,
[teml_request] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[teml_response] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[teml_url] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[teml_error] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[teml_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TruETAMessageLog_teml_createdby] DEFAULT (suser_name()),
[teml_createdon] [datetime] NULL CONSTRAINT [DF_TruETAMessageLog_teml_createdOn] DEFAULT (getdate()),
[teml_lastupdatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[teml_lastupdatedon] [datetime] NULL,
[teml_lastupdateapp] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TruETAMessageLog] ADD CONSTRAINT [PK_TruETAMessageLog] PRIMARY KEY CLUSTERED ([teml_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TruETAMessageLog] TO [public]
GO
GRANT INSERT ON  [dbo].[TruETAMessageLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TruETAMessageLog] TO [public]
GO
GRANT SELECT ON  [dbo].[TruETAMessageLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[TruETAMessageLog] TO [public]
GO
