CREATE TABLE [dbo].[cashcardtractor]
(
[cct_id] [int] NOT NULL IDENTITY(1, 1),
[crd_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cct_created_date] [datetime] NULL,
[cct_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cct_modified_date] [datetime] NULL,
[cct_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cashcardtractor] ADD CONSTRAINT [PK_cashcardtractor] PRIMARY KEY NONCLUSTERED ([cct_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cashcardtractor] TO [public]
GO
GRANT INSERT ON  [dbo].[cashcardtractor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cashcardtractor] TO [public]
GO
GRANT SELECT ON  [dbo].[cashcardtractor] TO [public]
GO
GRANT UPDATE ON  [dbo].[cashcardtractor] TO [public]
GO
