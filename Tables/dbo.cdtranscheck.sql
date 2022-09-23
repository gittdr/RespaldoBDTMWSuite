CREATE TABLE [dbo].[cdtranscheck]
(
[ctc_id] [int] NOT NULL IDENTITY(1, 1),
[ctc_available] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctc_accountnumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctc_branchnumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctc_booknumber] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctc_transactionnumber] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctc_expirationdate] [datetime] NOT NULL,
[ctc_checkamount] [money] NULL,
[ctc_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctc_asgnid] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctc_feetype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctc_issuedate] [datetime] NULL,
[ctc_issuedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctc_tripnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctc_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdtranscheck] ADD CONSTRAINT [PK__cdtranscheck__364019AA] PRIMARY KEY NONCLUSTERED ([ctc_id]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uk_cdtranscheck] ON [dbo].[cdtranscheck] ([ctc_accountnumber], [ctc_branchnumber], [ctc_booknumber], [ctc_transactionnumber], [ctc_expirationdate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdtranscheck] TO [public]
GO
GRANT INSERT ON  [dbo].[cdtranscheck] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdtranscheck] TO [public]
GO
GRANT SELECT ON  [dbo].[cdtranscheck] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdtranscheck] TO [public]
GO
