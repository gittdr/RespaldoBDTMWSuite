CREATE TABLE [dbo].[UserTypeAssignment]
(
[usr_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uta_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uta_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uta_flag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uta_expupdate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_UserTypeAssignment_rowsec] ON [dbo].[UserTypeAssignment]
FOR DELETE
AS
	--This will sync the existing revtype user assignments used in the new row security
	--As long as the setup is the same as what was supported in the 1st version.
	
	--PTS 59979 JJF 20111111 fixes to sync, preserve unknown wildcard
	
	SET NOCOUNT ON
	
	DECLARE @column_setup_revtype1 int
	DECLARE @column_setup_other int
	
	SELECT	@column_setup_revtype1 = count(*)
	FROM	RowSecColumns rsc
			INNER JOIN RowSecTables rst on rsc.rst_id = rst.rst_id
	WHERE	(rst.rst_table_name = 'TractorProfile' AND rsc_column_name = 'trc_terminal' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'company' AND rsc_column_name = 'cmp_revtype1' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'OrderHeader' AND rsc_column_name = 'ord_revtype1' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'ManpowerProfile' AND rsc_column_name = 'mpp_terminal' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'InvoiceHeader' AND rsc_column_name = 'ivh_revtype1' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'tariffkey' AND rsc_column_name = 'trk_rowsec_revtype1' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'averagefuelprice' AND rsc_column_name = 'afp_revtype1' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'cdcustcode' AND rsc_column_name = 'ccc_revtype1' AND rsc_sequence > 0)
			OR (rst.rst_table_name = 'TrailerProfile' AND rsc_column_name = 'trl_terminal' AND rsc_sequence > 0)

	SELECT	@column_setup_other = count(*)
	FROM	RowSecColumns rsc
			INNER JOIN RowSecTables rst on rsc.rst_id = rst.rst_id
	WHERE	NOT (	(rst.rst_table_name = 'TractorProfile' AND rsc_column_name = 'trc_terminal' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'company' AND rsc_column_name = 'cmp_revtype1' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'OrderHeader' AND rsc_column_name = 'ord_revtype1' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'ManpowerProfile' AND rsc_column_name = 'mpp_terminal' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'InvoiceHeader' AND rsc_column_name = 'ivh_revtype1' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'tariffkey' AND rsc_column_name = 'trk_rowsec_revtype1' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'averagefuelprice' AND rsc_column_name = 'afp_revtype1' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'cdcustcode' AND rsc_column_name = 'ccc_revtype1' AND rsc_sequence > 0)
				OR (rst.rst_table_name = 'TrailerProfile' AND rsc_column_name = 'trl_terminal' AND rsc_sequence > 0)
			) AND rsc_sequence > 0		

	IF 	@column_setup_revtype1 = 9 and @column_setup_other = 0 BEGIN
		--Sync up RowSecUserAssignments
		DELETE	RowSecUserAssignments
		FROM	RowSecUserAssignments rsua
				INNER JOIN RowSecColumnValues rscv on rsua.rscv_id = rscv.rscv_id
				INNER JOIN RowSecColumns rsc on rscv.rsc_id = rsc.rsc_id, 
				deleted d
		WHERE	rsua.usr_userid = d.usr_userid
				AND rscv.rscv_value = d.uta_type1
				AND (d.uta_type1 <> rsc.rsc_unknown_value)
				AND rsc.rsc_sequence > 0
				AND rsc.rsc_column_name in	(	'trc_terminal',
												'cmp_revtype1',
												'ord_revtype1',
												'mpp_terminal',
												'ivh_revtype1',
												'trk_rowsec_revtype1',
												'afp_revtype1',
												'ccc_revtype1',
												'trl_terminal'
											)
	
	END	
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_UserTypeAssignment_rowsec] ON [dbo].[UserTypeAssignment]
FOR INSERT, UPDATE
AS
       --This will sync the existing revtype user assignments used in the new row security
       --As long as the setup is the same as what was supported in the 1st version.

       --PTS 59979 JJF 20111111 fixes to sync, preserve unknown wildcard
       SET NOCOUNT ON
       
       DECLARE @column_setup_revtype1 int
       DECLARE @column_setup_other int
       
       
       SELECT @column_setup_revtype1 = count(*)
       FROM   RowSecColumns rsc
                     INNER JOIN RowSecTables rst on rsc.rst_id = rst.rst_id
       WHERE  (rst.rst_table_name = 'TractorProfile' AND rsc_column_name = 'trc_terminal' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'company' AND rsc_column_name = 'cmp_revtype1' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'OrderHeader' AND rsc_column_name = 'ord_revtype1' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'ManpowerProfile' AND rsc_column_name = 'mpp_terminal' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'InvoiceHeader' AND rsc_column_name = 'ivh_revtype1' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'tariffkey' AND rsc_column_name = 'trk_rowsec_revtype1' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'averagefuelprice' AND rsc_column_name = 'afp_revtype1' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'cdcustcode' AND rsc_column_name = 'ccc_revtype1' AND rsc_sequence > 0)
                     OR (rst.rst_table_name = 'TrailerProfile' AND rsc_column_name = 'trl_terminal' AND rsc_sequence > 0)

       SELECT @column_setup_other = count(*)
       FROM   RowSecColumns rsc
                     INNER JOIN RowSecTables rst on rsc.rst_id = rst.rst_id
       WHERE  NOT (  (rst.rst_table_name = 'TractorProfile' AND rsc_column_name = 'trc_terminal' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'company' AND rsc_column_name = 'cmp_revtype1' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'OrderHeader' AND rsc_column_name = 'ord_revtype1' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'ManpowerProfile' AND rsc_column_name = 'mpp_terminal' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'InvoiceHeader' AND rsc_column_name = 'ivh_revtype1' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'tariffkey' AND rsc_column_name = 'trk_rowsec_revtype1' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'averagefuelprice' AND rsc_column_name = 'afp_revtype1' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'cdcustcode' AND rsc_column_name = 'ccc_revtype1' AND rsc_sequence > 0)
                           OR (rst.rst_table_name = 'TrailerProfile' AND rsc_column_name = 'trl_terminal' AND rsc_sequence > 0)
                     ) AND rsc_sequence > 0            

       IF     @column_setup_revtype1 = 9 and @column_setup_other = 0 BEGIN
              --Sync up RowSecUserAssignments
              DELETE RowSecUserAssignments
              FROM   RowSecUserAssignments rsua
                           INNER JOIN RowSecColumnValues rscv on rsua.rscv_id = rscv.rscv_id
                           INNER JOIN RowSecColumns rsc on rscv.rsc_id = rsc.rsc_id, 
                           deleted d
              WHERE  rsua.usr_userid = d.usr_userid
                           AND rscv.rscv_value = d.uta_type1
                           AND (d.uta_type1 <> rsc.rsc_unknown_value)
                           AND rsc.rsc_sequence > 0
                           AND rsc.rsc_column_name in (      'trc_terminal',
                                                                                  'cmp_revtype1',
                                                                                  'ord_revtype1',
                                                                                  'mpp_terminal',
                                                                                  'ivh_revtype1',
                                                                                  'trk_rowsec_revtype1',
                                                                                  'afp_revtype1',
                                                                                  'ccc_revtype1',
                                                                                  'trl_terminal'
                                                                           )
       
              --63035 JJF 20120601 - add idtype
              INSERT RowSecUserAssignments      (
                     rsua_idtype,
                     usr_userid,
                     rscv_id
              )
              SELECT 'U',
                           i.usr_userid,
                           rscv.rscv_id
              FROM   RowSecColumnValues rscv 
                           INNER JOIN RowSecColumns rsc on rscv.rsc_id = rsc.rsc_id,
                           inserted i
              WHERE  rscv.rscv_value = i.uta_type1
                           AND rsc.rsc_sequence > 0
                           AND rsc.rsc_column_name in (      'trc_terminal',
                                                                                  'cmp_revtype1',
                                                                                  'ord_revtype1',
                                                                                  'mpp_terminal',
                                                                                  'ivh_revtype1',
                                                                                  'trk_rowsec_revtype1',
                                                                                  'afp_revtype1',
                                                                                  'ccc_revtype1',
                                                                                  'trl_terminal'
                                                                           )
                           AND NOT EXISTS       (             SELECT *
                                                                     FROM   RowSecColumnValues rscv 
                                                                                  INNER JOIN RowSecColumns rsc on rscv.rsc_id = rsc.rsc_id
                                                                                  INNER JOIN RowSecUserAssignments rsua on rsua.rscv_id = rscv.rscv_id,
                                                                                  inserted i
                                                                     WHERE  rscv.rscv_value = i.uta_type1
                                                                                  AND rsua.usr_userid = i.usr_userid
                                                                                  AND rsc.rsc_sequence > 0
                                                                                  AND rsc.rsc_column_name in     (      'trc_terminal',
                                                                                                                                         'cmp_revtype1',
                                                                                                                                         'ord_revtype1',
                                                                                                                                         'mpp_terminal',
                                                                                                                                         'ivh_revtype1',
                                                                                                                                         'trk_rowsec_revtype1',
                                                                                                                                         'afp_revtype1',
                                                                                                                                         'ccc_revtype1',
                                                                                                                                          'trl_terminal'
                                                                                                                                  )
                                                       )
              
       END
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_uta] ON [dbo].[UserTypeAssignment] ([usr_userid], [uta_type1]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UserTypeAssignment] TO [public]
GO
GRANT INSERT ON  [dbo].[UserTypeAssignment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[UserTypeAssignment] TO [public]
GO
GRANT SELECT ON  [dbo].[UserTypeAssignment] TO [public]
GO
GRANT UPDATE ON  [dbo].[UserTypeAssignment] TO [public]
GO
