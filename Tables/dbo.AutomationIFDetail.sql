CREATE TABLE [dbo].[AutomationIFDetail]
(
[IFName] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParmName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldNumber] [int] NULL,
[Offset] [int] NULL,
[Length] [int] NULL,
[FieldFormat] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutomationIFDetail] ADD CONSTRAINT [AutomationIFDetailKey] PRIMARY KEY CLUSTERED ([IFName], [ParmName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AutomationIFDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[AutomationIFDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AutomationIFDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[AutomationIFDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[AutomationIFDetail] TO [public]
GO
