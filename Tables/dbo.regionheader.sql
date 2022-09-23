CREATE TABLE [dbo].[regionheader]
(
[rgh_number] [int] NOT NULL,
[rgh_type] [int] NOT NULL,
[rgh_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rgh_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_regionheader]
ON [dbo].[regionheader]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE	@m2qhid		    INTEGER,
        @rgh_id             VARCHAR(6),
        @rgh_name           VARCHAR(30),
        @rgh_type           INTEGER

IF (SELECT UPPER(gi_string1) FROM generalinfo WHERE gi_name = 'MaptuitAlert') = 'Y'
BEGIN
   SELECT @rgh_id = isnull(rgh_id,''),
          @rgh_name = isnull(rgh_name,''),
          @rgh_type = isnull(rgh_type,'')
     FROM inserted
   IF @rgh_type = 1
   BEGIN
      EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
		VALUES (@m2qhid, 'Area_AreaID', 'HIL', @rgh_id)
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
		VALUES (@m2qhid, 'Area_AreaName', 'HIL', @rgh_name)
      INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
   END
END
	
GO
CREATE UNIQUE NONCLUSTERED INDEX [rgh_idx2] ON [dbo].[regionheader] ([rgh_id], [rgh_type]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_rgh_number] ON [dbo].[regionheader] ([rgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_regionheader_timestamp] ON [dbo].[regionheader] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[regionheader] TO [public]
GO
GRANT INSERT ON  [dbo].[regionheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[regionheader] TO [public]
GO
GRANT SELECT ON  [dbo].[regionheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[regionheader] TO [public]
GO
