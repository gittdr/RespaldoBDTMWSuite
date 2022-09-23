CREATE TABLE [dbo].[tblRSbup]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[keyCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[text] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[static] [bit] NOT NULL CONSTRAINT [DF_tblRSS_static_1__29] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRSbup] ADD CONSTRAINT [PK_tblRSR_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblRSbup] TO [public]
GO
GRANT INSERT ON  [dbo].[tblRSbup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblRSbup] TO [public]
GO
GRANT SELECT ON  [dbo].[tblRSbup] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblRSbup] TO [public]
GO
GRANT VIEW CHANGE TRACKING ON  [dbo].[tblRSbup] TO [public]
GO
