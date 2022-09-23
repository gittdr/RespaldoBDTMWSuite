CREATE TABLE [dbo].[cdunvcard]
(
[unvcard_id] [int] NOT NULL IDENTITY(1, 1),
[request_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[control_card] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[access_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trans_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_amt] [decimal] (18, 4) NULL,
[cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[memo_field] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_sent] [datetime] NULL,
[pyd_number] [int] NULL,
[sent_packet] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[received_packet] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdunvcard] ADD CONSTRAINT [PK__cdunvcard__4B1C0656] PRIMARY KEY CLUSTERED ([unvcard_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdunvcard] TO [public]
GO
GRANT INSERT ON  [dbo].[cdunvcard] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdunvcard] TO [public]
GO
GRANT SELECT ON  [dbo].[cdunvcard] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdunvcard] TO [public]
GO
