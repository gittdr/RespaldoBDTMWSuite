CREATE TABLE [dbo].[CarrierQualificationInfoDtl]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[CarrierQualificationInfoHdr_id] [int] NOT NULL,
[ParentId] [int] NULL,
[elementname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[keyname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[keyvalue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[keyvaluedatatype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CarrierQu__keyva__1F0EFE12] DEFAULT ('S'),
[Remarks] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[keyvalueString] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[keyvalueNumber] [decimal] (19, 6) NULL,
[keyvalueDateTime] [datetime] NULL,
[isSystemKey] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CarrierQu__isSys__2003224B] DEFAULT ('N'),
[isExpandable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CarrierQu__isExp__20F74684] DEFAULT ('Y'),
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__CarrierQu__lastu__21EB6ABD] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CarrierQu__lastu__22DF8EF6] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierQualificationInfoDtl] ADD CONSTRAINT [pk_CarrierQualificationInfoDtl] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierQualificationInfoDtl_CarrierQualificationInfoHdr_id] ON [dbo].[CarrierQualificationInfoDtl] ([CarrierQualificationInfoHdr_id]) INCLUDE ([id], [elementname], [keyname], [keyvalue], [keyvaluedatatype], [keyvalueString], [keyvalueNumber], [keyvalueDateTime]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierQualificationInfoDtl_AllKeys] ON [dbo].[CarrierQualificationInfoDtl] ([CarrierQualificationInfoHdr_id], [elementname], [keyname]) INCLUDE ([id], [ParentId], [keyvalue], [keyvaluedatatype], [keyvalueString], [keyvalueNumber], [keyvalueDateTime]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierQualificationInfoDtl] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierQualificationInfoDtl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierQualificationInfoDtl] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierQualificationInfoDtl] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierQualificationInfoDtl] TO [public]
GO
