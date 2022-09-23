CREATE TABLE [dbo].[CmpOrdReqAddtlProReq]
(
[corapr_id] [int] NOT NULL IDENTITY(1, 1),
[prq_id] [int] NOT NULL,
[corapr_seq] [int] NULL,
[revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CmpOrdReqAddtlProReq] ADD CONSTRAINT [pk_corapr_id] PRIMARY KEY CLUSTERED ([corapr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CmpOrdReqAddtlProReq] TO [public]
GO
GRANT INSERT ON  [dbo].[CmpOrdReqAddtlProReq] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CmpOrdReqAddtlProReq] TO [public]
GO
GRANT SELECT ON  [dbo].[CmpOrdReqAddtlProReq] TO [public]
GO
GRANT UPDATE ON  [dbo].[CmpOrdReqAddtlProReq] TO [public]
GO
