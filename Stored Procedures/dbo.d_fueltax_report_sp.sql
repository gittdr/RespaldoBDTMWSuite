SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_fueltax_report_sp    Script Date: 6/1/99 11:54:11 AM ******/
create PROC [dbo].[d_fueltax_report_sp]
@BegDate			datetime,
@EndDate			datetime,
@Owner			varchar (12),
@TrcType1		varchar (6),
@TrcType2		varchar (6),
@TrcType3		varchar (6),
@TrcType4		varchar (6),
@Company			varchar (6),
@Division		varchar (6),
@Fleet			varchar (6),
@Terminal		varchar (6),
@Rest				varchar (15),
@R_Val			varchar (20),
@uom				varchar (8)

AS

CREATE TABLE #fueltaxreport
(ftr_begdate	datetime	null,
ftr_enddate		datetime	null,
ftr_state		char (2)	null,
ftr_taxrate		float				null,
ftr_pumprate	float				null,
ftr_instate		float		null,
ftr_total		float		null,
ftr_free			float		null,
ftr_toll			float		null,
ftr_quantity	float		null,
ftr_consumed	float		null,
ftr_balance		float		null,
ftr_tax			money		null,
ftr_paid			money		null,
ftr_2ndtier		money		null,
ftr_due			money		null,
ftr_owner		varchar (12)	null,
ftr_type1		varchar (6)		null,
ftr_type2		varchar (6)		null,
ftr_type3		varchar (6)		null,
ftr_type4		varchar (6)		null,
ftr_company		varchar (6)		null,
ftr_division	varchar (6)		null,
ftr_fleet		varchar (6)		null,
ftr_terminal	varchar (6)		null,
ftr_method		varchar (10)	null,
ftr_mpg			float				null,
ftr_uom			varchar (8)		null)

CREATE TABLE #fueltaxtemp
(ftr_begdate	datetime			null,
ftr_enddate		datetime			null,
ftr_state		char (2)			null,
ftr_total		float				null,
ftr_free			float				null,
ftr_toll			float				null,
ftr_quantity	float				null,
ftr_owner		varchar (12)	null,
ftr_type1		varchar (6)		null,
ftr_type2		varchar (6)		null,
ftr_type3		varchar (6)		null,
ftr_type4		varchar (6)		null,
ftr_company		varchar (6)		null,
ftr_division	varchar (6)		null,
ftr_fleet		varchar (6)		null,
ftr_terminal	varchar (6)		null,
ftr_uom			varchar (8)		null)

    
INSERT INTO #fueltaxtemp (ftr_state, ftr_total, ftr_free, ftr_toll, ftr_quantity,
ftr_owner, ftr_type1, ftr_type2, ftr_type3, ftr_type4, ftr_company, ftr_division,
ftr_fleet, ftr_terminal, ftr_uom)
SELECT f.ft_state, sum(f.ft_total), sum(f.ft_free), sum(f.ft_toll), 0, t.trc_owner,
t.trc_type1, t.trc_type2, t.trc_type3, t.trc_type4, t.trc_company,
t.trc_division, t.trc_fleet, t.trc_terminal, f.ft_uom
FROM fueltax f, tractorprofile t
WHERE f.ft_date BETWEEN @BegDate AND @EndDate and
f.trc_number	= t.trc_number and
@Owner in ("UNKNOWN", t.trc_owner) and
@TrcType1 in ("UNK", t.trc_type1) and
@TrcType2 in ("UNK", t.trc_type2) and
@TrcType3 in ("UNK", t.trc_type3) and
@TrcType4 in ("UNK", t.trc_type4) and
@Company in ("UNK", t.trc_company) and
@Division in ("UNK", t.trc_division) and
@Fleet in ("UNK", t.trc_fleet) and
@Terminal in ("UNK", t.trc_terminal)
GROUP BY f.ft_state, t.trc_owner, t.trc_type1, t.trc_type2, t.trc_type3, t.trc_type4,
t.trc_company, t.trc_division, t.trc_fleet, t.trc_terminal, f.ft_uom
ORDER BY f.ft_state

                                         
INSERT INTO #fueltaxtemp (ftr_state, ftr_total, ftr_free, ftr_toll, ftr_quantity,
ftr_owner, ftr_type1, ftr_type2, ftr_type3, ftr_type4, ftr_company, ftr_division,
ftr_fleet, ftr_terminal, ftr_uom)
SELECT p.fp_state, 0,0, 0, sum(p.fp_quantity), t.trc_owner,
t.trc_type1, t.trc_type2, t.trc_type3, t.trc_type4, t.trc_company,
t.trc_division, t.trc_fleet, t.trc_terminal, p.fp_uom
FROM fuelpurchased p, tractorprofile t
WHERE p.fp_date BETWEEN @BegDate AND @EndDate and
p.trc_number	= t.trc_number and
@Owner in ("UNKNOWN", t.trc_owner) and
@TrcType1 in ("UNK", t.trc_type1) and
@TrcType2 in ("UNK", t.trc_type2) and
@TrcType3 in ("UNK", t.trc_type3) and
@TrcType4 in ("UNK", t.trc_type4) and
@Company in ("UNK", t.trc_company) and
@Division in ("UNK", t.trc_division) and
@Fleet in ("UNK", t.trc_fleet) and
@Terminal in ("UNK", t.trc_terminal)
GROUP BY p.fp_state, t.trc_owner, t.trc_type1,t.trc_type2, t.trc_type3, t.trc_type4,
t.trc_company, t.trc_division, t.trc_fleet, t.trc_terminal, p.fp_uom
ORDER BY p.fp_state

select * from #fueltaxtemp
                                                                         
UPDATE #fueltaxtemp SET ftr_begdate = @BegDate, ftr_enddate = @EndDate
                                         
DECLARE @tot_miles float, @tot_fuel float, @avg_mpg float

SELECT @tot_miles = sum(ftr_total), @tot_fuel = sum(ftr_quantity) 
FROM #fueltaxtemp

SELECT @avg_mpg = @tot_miles /@tot_fuel

                      
INSERT INTO #fueltaxreport
(ftr_begdate, 					ftr_enddate, 					ftr_state,			
ftr_taxrate,					ftr_pumprate,					ftr_instate,					
ftr_total,				
ftr_free,						ftr_toll,						ftr_quantity,		
ftr_consumed,					ftr_balance, 					ftr_tax,
ftr_paid,						ftr_2ndtier,					ftr_due,				
ftr_owner,						ftr_type1,						ftr_type2,				
ftr_type3,						ftr_type4,						ftr_company,		
ftr_division,					ftr_fleet,						ftr_terminal)
SELECT @BegDate,						@EndDate,						f.ftr_state,
0,								0,									sum(f.ftr_total)/@tot_miles,
sum(f.ftr_total),		
sum(f.ftr_free),				sum(f.ftr_toll),				sum(f.ftr_quantity), 	
ROUND((sum(f.ftr_total)/@avg_mpg),2), 	0,				0,
0,								0,									0,
f.ftr_owner,					f.ftr_type1,					f.ftr_type2,				
f.ftr_type3,					f.ftr_type4,					f.ftr_company,		
f.ftr_division,				f.ftr_fleet,					f.ftr_terminal
FROM #fueltaxtemp f
GROUP BY f.ftr_state, f.ftr_owner, f.ftr_type1, f.ftr_type2, 
f.ftr_type3, f.ftr_type4,	f.ftr_company,
f.ftr_division, f.ftr_fleet, f.ftr_terminal

                                        
UPDATE #fueltaxreport SET 	ftr_taxrate = s.st_diesel_rate,
ftr_pumprate = s.st_pump_rate,
ftr_method	= s.st_method,
ftr_mpg		= s.st_mpg
FROM #fueltaxreport f, stateprofile s
WHERE f.ftr_state = s.st_abbr

                                                       
If (@uom = "LTR")
BEGIN
	UPDATE #fueltaxreport SET ftr_quantity = ROUND((ftr_quantity * 3.785), 2),	
									  ftr_uom		= "LTR"
	 WHERE ftr_uom = "GAL"

	UPDATE #fueltaxreport SET ftr_total	= ROUND((ftr_total * 1.609), 2),
									  ftr_free	= ROUND((ftr_free * 1.609), 2),
									  ftr_toll	= ROUND((ftr_toll * 1.609), 2),
									  ftr_uom	= "KMS"
	 WHERE ftr_uom 	= "MIL"
END
Else
BEGIN
	UPDATE #fueltaxreport SET ftr_quantity = ROUND((ftr_quantity * 0.264), 2),	
	  ftr_uom		= "GAL"
	 WHERE ftr_uom = "LTR"

	UPDATE #fueltaxreport SET ftr_total	= ROUND((ftr_total * .621), 2),
	  ftr_free	= ROUND((ftr_free * .621),2),
	  ftr_toll	= ROUND((ftr_toll * .621), 2),
	  ftr_uom	= "MIL"
	 WHERE ftr_uom 	= "KMS"
END

      
UPDATE #fueltaxreport SET 	ftr_consumed 	= ROUND((ftr_total / ftr_mpg), 2)
WHERE ftr_method = "FixedMPG"

   
UPDATE #fueltaxreport SET 	ftr_consumed	= ROUND((ftr_instate * @tot_fuel), 2)
WHERE ftr_method = "InState"

                  
UPDATE #fueltaxreport SET	ftr_balance = round((ftr_consumed - ftr_quantity), 0),
ftr_tax		= round((ftr_taxrate * ftr_consumed), 2),
ftr_paid		= round((ftr_pumprate * ftr_quantity), 2)

        
UPDATE #fueltaxreport SET	ftr_due		= ftr_tax - ftr_paid

SELECT	ftr_begdate,
ftr_enddate,
ftr_state,
ftr_taxrate,
ftr_pumprate,
ftr_instate,
ftr_total,
ftr_free,
ftr_toll,
ftr_quantity,
ftr_consumed,
ftr_balance,
ftr_tax,
ftr_paid,
ftr_2ndtier,
ftr_due,
ftr_owner,
ftr_type1,
ftr_type2,
ftr_type3,
ftr_type4,
ftr_company,
ftr_division,
ftr_fleet,
ftr_terminal,	
@Rest,
@R_Val,
@uom
FROM #fueltaxreport
ORDER BY ftr_company, ftr_state

return
 




GO
GRANT EXECUTE ON  [dbo].[d_fueltax_report_sp] TO [public]
GO
