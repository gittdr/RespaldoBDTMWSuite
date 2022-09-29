CREATE TABLE [dbo].[commodityclass2]
(
[ccl_number] [int] NOT NULL IDENTITY(1, 1),
[ccl_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccl_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccl_isretired] [bit] NOT NULL CONSTRAINT [DF__commodity__ccl_i__34550770] DEFAULT ((0)),
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__commodity__cmd_c__3A0DE0C6] DEFAULT ('UNKNOWN'),
[default_uom] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccl_displayorder] [int] NULL,
[ccl_exclusive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__commodity__ccl_e__568D513F] DEFAULT ('N'),
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__commodity__INS_T__3F86210F] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodityclass2] ADD CONSTRAINT [pk_commodityclass2_ccl_number] PRIMARY KEY CLUSTERED ([ccl_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodityclass2_INS_TIMESTAMP] ON [dbo].[commodityclass2] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodityclass2] TO [public]
GO
GRANT INSERT ON  [dbo].[commodityclass2] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodityclass2] TO [public]
GO
GRANT SELECT ON  [dbo].[commodityclass2] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodityclass2] TO [public]
GO
