CREATE TABLE [dbo].[mileageserver_log]
(
[msl_identity] [int] NOT NULL IDENTITY(1, 1),
[msl_session] [int] NOT NULL,
[msl_datetime] [datetime] NOT NULL,
[msl_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msl_text] [varchar] (7500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msl_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msl_type] [int] NULL,
[msl_origin] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msl_destination] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msl_origin_text] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msl_destination_text] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mileageserver_log] ADD CONSTRAINT [PK_msl_ident] PRIMARY KEY CLUSTERED ([msl_identity]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[mileageserver_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[mileageserver_log] TO [public]
GO
GRANT SELECT ON  [dbo].[mileageserver_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[mileageserver_log] TO [public]
GO
