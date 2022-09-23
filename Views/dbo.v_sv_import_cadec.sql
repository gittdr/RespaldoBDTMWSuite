SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[v_sv_import_cadec] AS
SELECT	imp_batch,
		imp_id,
		dist_center,
		record_type,
		trip_date,
		trip_num,
		event_type,
		CONVERT(DATETIME, RIGHT('20' + RTRIM(field5), 8) + ' ' + LEFT(RTRIM(field6), 2) + ':' + RIGHT(RTRIM(field6), 2)) event_start_date,
		CONVERT(DATETIME, RIGHT('20' + RTRIM(field7), 8) + ' ' + LEFT(RTRIM(field8), 2) + ':' + RIGHT(RTRIM(field8), 2)) event_end_date,
		CONVERT(INTEGER, RTRIM(field9)) event_duration,
		CASE 
			WHEN ISNUMERIC(RTRIM(field10)) = 1 THEN CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field10)))
			ELSE CONVERT(VARCHAR(8), RTRIM(field10)) 
		END driver,
		CASE event_type
			WHEN '03' THEN CASE
							   WHEN ISNUMERIC(RTRIM(field11)) = 1 THEN CASE
																	WHEN CONVERT(INTEGER, field11) = dist_center THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																	ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																END
							   ELSE	RTRIM(field11)
						   END
			WHEN '30' THEN CASE
							   WHEN ISNUMERIC(RTRIM(field12)) = 1 THEN CASE
																	WHEN CONVERT(INTEGER, field12) = dist_center THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																	ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																END
							   ELSE	RTRIM(field12)
						   END
			WHEN '35' THEN CASE
							   WHEN ISNUMERIC(RTRIM(field12)) = 1 THEN CASE
																	WHEN CONVERT(INTEGER, field12) = dist_center THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																	ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																END
							   ELSE	RTRIM(field12)
						   END
			WHEN '39' THEN CASE
							   WHEN ISNUMERIC(RTRIM(field11)) = 1 THEN CASE
																	WHEN CONVERT(INTEGER, field11) = dist_center THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																	ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																END
							   ELSE	RTRIM(field11)
						   END
			WHEN '93' THEN CASE
							   WHEN ISNUMERIC(RTRIM(field12)) = 1 THEN CASE
																	WHEN CONVERT(INTEGER, field12) = dist_center THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																	ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																END
							   ELSE	RTRIM(field12)
						   END
			WHEN '97' THEN CASE
							   WHEN ISNUMERIC(RTRIM(field11)) = 1 THEN CASE
																	WHEN CONVERT(INTEGER, field11) = dist_center THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																	ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																END
							   ELSE	RTRIM(field11)
						   END
			ELSE NULL
		END location,
		CASE event_type
			WHEN '39' THEN RTRIM(field13)
			ELSE NULL
		END drop_trailer1,
		CASE event_type
			WHEN '39' THEN RTRIM(field14)
			ELSE NULL
		END drop_trailer2,
		CASE event_type
			WHEN '39' THEN RTRIM(field15)
			ELSE NULL
		END drop_trailer3,
		CASE event_type
			WHEN '39' THEN RTRIM(field16)
			ELSE NULL
		END hook_trailer1,
		CASE event_type
			WHEN '39' THEN RTRIM(field17)
			ELSE NULL
		END hook_trailer2,
		CASE event_type
			WHEN '39' THEN RTRIM(field18)
			ELSE NULL
		END hook_trailer3
  FROM	sv_import_cadec_actual_route
 WHERE	event_type IN ('03', '30', '35', '39', '93', '97')
GO
GRANT DELETE ON  [dbo].[v_sv_import_cadec] TO [public]
GO
GRANT INSERT ON  [dbo].[v_sv_import_cadec] TO [public]
GO
GRANT SELECT ON  [dbo].[v_sv_import_cadec] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_sv_import_cadec] TO [public]
GO
