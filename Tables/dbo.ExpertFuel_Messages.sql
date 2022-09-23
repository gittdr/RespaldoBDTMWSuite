CREATE TABLE [dbo].[ExpertFuel_Messages]
(
[em_id] [int] NOT NULL IDENTITY(1, 1),
[gf_requestid] [int] NULL,
[gf_lgh_number] [int] NULL,
[gf_city_cmp] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[em_messagetext] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[em_senddate] [datetime] NULL,
[em_requestby] [datetime] NULL,
[em_sendby] [datetime] NULL,
[em_sendapp] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[em_formid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ExpertFuel_Messages] TO [public]
GO
GRANT INSERT ON  [dbo].[ExpertFuel_Messages] TO [public]
GO
GRANT SELECT ON  [dbo].[ExpertFuel_Messages] TO [public]
GO
GRANT UPDATE ON  [dbo].[ExpertFuel_Messages] TO [public]
GO
