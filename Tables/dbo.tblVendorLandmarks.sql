CREATE TABLE [dbo].[tblVendorLandmarks]
(
[vlm_ID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vlm_vendorId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vlm_vendorLandmarkId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vlm_landmarkName] [nvarchar] (110) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vlm_fenceRadiusMeters] [numeric] (18, 0) NULL,
[vlm_instanceId] [int] NULL CONSTRAINT [DF_vlm_instanceId] DEFAULT ((1)),
[vlm_pushdate] [datetime] NOT NULL CONSTRAINT [DF_vlm_pushdate] DEFAULT (getdate()),
[vlm_createddate] [datetime] NOT NULL CONSTRAINT [DF_vlm_createddate] DEFAULT (getdate()),
[vlm_Status] [tinyint] NOT NULL CONSTRAINT [DF__tblVendor__vlm_S__4A78E6C7] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVendorLandmarks] ADD CONSTRAINT [PK_tblVendorLandmarks] PRIMARY KEY CLUSTERED ([vlm_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblVendorLandmarks] TO [public]
GO
GRANT INSERT ON  [dbo].[tblVendorLandmarks] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblVendorLandmarks] TO [public]
GO
GRANT SELECT ON  [dbo].[tblVendorLandmarks] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblVendorLandmarks] TO [public]
GO
