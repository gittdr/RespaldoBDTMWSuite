CREATE TABLE [dbo].[OutOfRouteTolerance]
(
[oort_labeldefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[oort_labelabbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[oort_toleranceMiles] [int] NOT NULL,
[oort_lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oort_lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OutOfRouteTolerance] ADD CONSTRAINT [PK_OutOfRouteTolerance] PRIMARY KEY CLUSTERED ([oort_labeldefinition], [oort_labelabbr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OutOfRouteTolerance] TO [public]
GO
GRANT INSERT ON  [dbo].[OutOfRouteTolerance] TO [public]
GO
GRANT SELECT ON  [dbo].[OutOfRouteTolerance] TO [public]
GO
GRANT UPDATE ON  [dbo].[OutOfRouteTolerance] TO [public]
GO
