CREATE TABLE [dbo].[socketprofile]
(
[skt_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[skt_desc] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[skt_addfamily] [tinyint] NOT NULL CONSTRAINT [df_socketprofile_skt_addfamily] DEFAULT (2),
[skt_type] [tinyint] NOT NULL CONSTRAINT [df_socketprofile_skt_type] DEFAULT (1),
[skt_protocol] [tinyint] NOT NULL CONSTRAINT [df_socketprofile_skt_protocol] DEFAULT (6),
[skt_namelength] [tinyint] NOT NULL CONSTRAINT [df_socketprofile_skt_namelength] DEFAULT (16),
[skt_ipaddress] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[skt_port] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[socketprofile] ADD CONSTRAINT [pk_socketprofile] PRIMARY KEY CLUSTERED ([skt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[socketprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[socketprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[socketprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[socketprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[socketprofile] TO [public]
GO
