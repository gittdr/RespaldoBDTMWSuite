SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_ace_companydata]	@p_ordnum varchar(13),@p_mov_number int

AS
/**
 * 
 * NAME:
 * dbo.d_ace_companydata
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves company detail information for the ace 309/358 creation window in visual dispatch.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * all columns in #company_profile temp table
 *
 * PARAMETERS:
 * 001 - @p_ordnum, varchar(13), input;
 *       This parameter indicates the order number in which related data is being retrieved
 * 002 - @p_mov_number input not null;
 *	 Move number being retrieved.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? Name of Proc / Function Called
 * 
 * REVISION HISTORY:
 * 03/1/2006.01 ? PTS31886 - A. Rossman ? Initial Release
 * 04/10/2006.02 - PTS32515 - A.Rossman - Return only one email address per company id.
 * 02/23/2006.03 - PTS 32601 - A. Rossman - Added move number to parameter list.
 * 06/06/2006.04 - PTS 33469 - A.Rossmsn - Add logic for roundtrips. Display multiple shipper and consignee locations when necessary
 * 04/23/2007.05 - PTS 37189 - A.Rossman -  Updated logic for Mexican shipments.
 * 11/26/2007.06 - PTS 39885 - A. Rossman - Fixes for data retrieval. Get data from stops for empty movements.
 * 01/17/2008.07 - PTS 41005 - A. Rossman - Get movement number from first Delivery for in-transit movements.
 * 02/25/2008.08 - PTS 41340 - A. Rossman - Added the ord_number to the result set.
 * 10/15/2008.09 - PTS 44804 - A.Rossman - Updated port location retrieval.
 **/

DECLARE	@v_shipper varchar(8),@v_consignee varchar(8), @v_billto varchar(8), @v_broker	varchar(8),
	@v_mov_number int,@v_MT char(1),@v_ord_hdrnumber int

DECLARE @v_isroundtrip char(1),@v_origin varchar(8), @v_destination varchar(8),@v_originstate varchar(6),@v_deststate varchar(6),
	@v_origincountry varchar(50), @v_destcountry varchar(50)


--CREATE TABLE #company_profile 
DECLARE @company_profile TABLE(
		cmp_id		varchar(8)	NULL,
		cmp_role 	varchar(3)	NULL,	--BT,CN,SH,BR
		cmp_name	varchar(50)	NULL,
		cmp_address1	varchar(50)	NULL,
		cmp_address2	varchar(50)	NULL,
		cmp_city	varchar(35)	NULL,
		cmp_state	varchar(6)	NULL,
		cmp_country	varchar(6)	NULL,
		cmp_aceidtype	varchar(6)	NULL,
		cmp_aceid	varchar(30)	NULL,
		cmp_contact	varchar(30)	NULL,
		cmp_phone	varchar(20)	NULL,
		cmp_email	varchar(80)	NULL,
		cmp_zip		varchar(10)     NULL,
		ord_hdrnumber int	 NULL,					--39508		
		ord_number varchar(12) NULL
		
		)
	
	--PTS 39508
create table #movs (mov_number int)
  

/*IF @p_mov_number > 0 
   SELECT @v_mov_number = @p_mov_number
ELSE   
	SELECT @v_mov_number = mov_number,
		@v_MT = 'N'
	FROM	orderheader
	WHERE	ord_number = @p_ordnum	*/
	
	
--Use the input move number when necessary.
IF @p_mov_number > 0
	SELECT @v_mov_number = @p_mov_number,
		@v_ord_hdrnumber = MAX(DISTINCT(ord_hdrnumber ))
	FROM	legheader
	WHERE	mov_number = @p_mov_number
ELSE	
	BEGIN
		SELECT @v_ord_hdrnumber = ord_hdrnumber
		FROM 	orderheader WHERE ord_number = @p_ordnum
		--get the move from the delivery stop
		SELECT @v_mov_number = mov_number
		FROM 	  stops s
				inner join statecountry st on s.stp_state = st.stc_state_c
		WHERE ord_hdrnumber = @v_ord_hdrnumber
			AND stp_type = 'DRP'
			AND stc_country_c = 'USA'
	END		
	
	/*PTS 41005 - Special code for in-transit movements through US. Get movement from first delivery stop. */
	IF (SELECT ISNULL(@v_mov_number,0)) = 0
		SELECT @v_mov_number = MAX(mov_number)
		FROM		Stops
		WHERE	ord_hdrnumber = @v_ord_hdrnumber
				AND stp_type = 'DRP'
	/* END 41005 */				
	
insert #movs 
select stops.mov_number  from stops inner join stops stops2 on stops.ord_hdrnumber = stops2.ord_hdrnumber
where stops2.mov_number = @v_mov_number and stops2.ord_hdrnumber > 0
group by stops.mov_number	

--determine if this is an empty move or not.
IF @v_ord_hdrnumber = 0
	SET @v_MT = 'Y'
ELSE 
	SET @v_MT = 'N'	

/*determine if this is a roundtrip or not*/
IF @v_mov_number > 0
BEGIN
	SELECT @v_origin = cmp_id, @v_originstate = stp_state, @v_origincountry = stc_country_c  
	FROM stops 
	 join statecountry
	 	on stp_state = stc_state_c
	WHERE  stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE ord_hdrnumber =@v_ord_hdrnumber AND stp_type = 'PUP') 
		AND ord_hdrnumber = @v_ord_hdrnumber
		AND stp_type = 'PUP'
	
	
	
	SELECT @v_destination = cmp_id,@v_deststate = stp_state,@v_destcountry = stc_country_c 
	FROM stops 
		JOIN statecountry
			on stp_state = stc_state_c
	WHERE stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number)
	AND mov_number = @v_mov_number
	
	IF @v_origin = @v_destination or (@v_originstate = @v_deststate AND @v_origincountry = @v_destcountry)
		SET @v_isroundtrip = 'Y'
	ELSE
		SET @v_isroundtrip = 'N'
		
END		
	
		
IF (SELECT MAX(DISTINCT(ord_hdrnumber)) FROM legheader WHERE mov_number = @v_mov_number) = 0
	SET @v_MT = 'Y'

	IF @v_MT = 'Y'
		INSERT INTO @company_profile			--SHIPPER
		SELECT	s.cmp_id,
			'SH',
			LEFT(s.cmp_name,50),
			ISNULL(LEFT(s.stp_address,50),''),
			ISNULL(LEFT(s.stp_address2,50),''),
			(ci.cty_name),
			ISNULL(ci.cty_state,'XX'),
			LEFT(ci.cty_country,3),
			' ',			--aceid
			'UNK',		--aceid type
			ISNULL(s.stp_contact,' '),
			ISNULL(s.stp_phonenumber,' '),
			' ',
			ISNULL(ci.cty_zip,' '),
			s.ord_hdrnumber,
			0
		FROM	stops s
			JOIN city  ci
				ON s.stp_city = ci.cty_code
		WHERE	mov_number = @v_mov_number
			AND stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number)
		
		
		/*SELECT @v_shipper = cmp_id
		FROM	stops
		WHERE	mov_number = @v_mov_number 
		AND stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number) */
	ELSE
		
		IF (SELECT COUNT(*) FROM stops WHERE ord_hdrnumber in (Select ord_hdrnumber FROM stops  WHERE mov_number = @v_mov_number and ord_hdrnumber > 0 )--WHERE mov_number = @v_mov_number and stp_type = 'PUP' and 
			and stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c in( 'CANADA', 'MEXICO'))) > 0
		--Get the company information
			INSERT INTO @company_profile			--SHIPPER
			SELECT	c.cmp_id,
				'SH',
				LEFT(c.cmp_name,50),
				ISNULL(LEFT(c.cmp_address1,50),''),
				ISNULL(LEFT(c.cmp_address2,50),''),
				LEFT(c.cty_nmstct, CHARINDEX(',',c.cty_nmstct,0)-1),
				SUBSTRING(c.cty_nmstct,CHARINDEX(',',c.cty_nmstct,0)+1,2),
				LEFT(c.cmp_country,3),
				ISNULL(c.cmp_aceidtype,'UNK'),
				ISNULL(c.cmp_aceid,' '),
				ISNULL(c.cmp_contact,' '),
				ISNULL(c.cmp_primaryphone,' '),
				' ',
				ISNULL(c.cmp_zip,' '),
				s.ord_hdrnumber,
				0
			FROM	company c
				JOIN stops s
					ON s.cmp_id = c.cmp_id
			WHERE	s.ord_hdrnumber in (select ord_hdrnumber from stops where mov_number  = @v_mov_number and ord_hdrnumber  > 0)
				AND stp_type = 'PUP'
				AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c in('CANADA','MEXICO'))
				
		ELSE
			IF (SELECT COUNT(*) FROM STOPS WHERE ord_hdrnumber = @v_ord_hdrnumber and stp_type = 'PUP' and 
			stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c in ('CANADA','MEXICO'))) > 0
			--Get shipper info based on the ordernumber
			INSERT INTO @company_profile			--SHIPPER
			SELECT	c.cmp_id,
				'SH',
				LEFT(c.cmp_name,50),
				ISNULL(LEFT(c.cmp_address1,50),''),
				ISNULL(LEFT(c.cmp_address2,50),''),
				LEFT(c.cty_nmstct, CHARINDEX(',',c.cty_nmstct,0)-1),
				SUBSTRING(c.cty_nmstct,CHARINDEX(',',c.cty_nmstct,0)+1,2),
				LEFT(c.cmp_country,3),
				ISNULL(c.cmp_aceidtype,'UNK'),
				ISNULL(c.cmp_aceid,' '),
				ISNULL(c.cmp_contact,' '),
				ISNULL(c.cmp_primaryphone,' '),
				' ',
				ISNULL(c.cmp_zip,' '),
				s.ord_hdrnumber,
				0
			FROM	company c
				JOIN stops s
					ON s.cmp_id = c.cmp_id
			WHERE	s.ord_hdrnumber = @v_ord_hdrnumber 
				AND stp_type = 'PUP'
				AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='CANADA')
			ELSE	/*if there are no pickups in CANADA associated with the move or the order, get the first Canadian stop for the move */
				INSERT INTO @company_profile			--SHIPPER
				SELECT	c.cmp_id,
					'SH',
					LEFT(c.cmp_name,50),
					ISNULL(LEFT(c.cmp_address1,50),''),
					ISNULL(LEFT(c.cmp_address2,50),''),
					LEFT(c.cty_nmstct, CHARINDEX(',',c.cty_nmstct,0)-1),
					SUBSTRING(c.cty_nmstct,CHARINDEX(',',c.cty_nmstct,0)+1,2),
					LEFT(c.cmp_country,3),
					ISNULL(c.cmp_aceidtype,'UNK'),
					ISNULL(c.cmp_aceid,' '),
					ISNULL(c.cmp_contact,' '),
					ISNULL(c.cmp_primaryphone,' '),
					' ',
					ISNULL(c.cmp_zip,' '),
					s.ord_hdrnumber,
					0
				FROM	company c
					JOIN stops s
						ON s.cmp_id = c.cmp_id
				WHERE	s.mov_number = @v_mov_number
					AND stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number
					AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c in('CANADA','MEXICO')) )
					and stp_type = 'PUP'
		
		
		/*SELECT	 @v_shipper =  cmp_id 		--shipper
		FROM	 stops 
		WHERE	 stp_type = 'PUP' 
				and stp_sequence = (SELECT MIN(stp_sequence) FROM stops	WHERE ord_hdrnumber = @v_ord_hdrnumber	AND stp_type = 'PUP')
				and ord_hdrnumber = @v_ord_hdrnumber	*/
	
	IF @v_MT = 'Y'
		
		
		INSERT INTO @company_profile			--CONSIGNEE
		SELECT	s.cmp_id,
			'CN',
			LEFT(s.cmp_name,50),
			ISNULL(LEFT(s.stp_address,50),''),
			ISNULL(LEFT(s.stp_address2,50),''),
			ci.cty_name,
			ISNULL(ci.cty_state,'XX'),
			LEFT(ci.cty_country,3),
			'UNK',				--aceid type
			' ',					--ace id
			ISNULL(s.stp_contact,' '),
			ISNULL(s.stp_phonenumber,' '),
			' ',
			ISNULL(ci.cty_zip,' '),
			s.ord_hdrnumber,
			0
		FROM	stops s
			JOIN city ci
				ON s.stp_city = ci.cty_code
		WHERE	s.mov_number = @v_mov_number
			AND stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number)
			AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA')
		
		/*SELECT @v_consignee = cmp_id
		FROM	stops
		WHERE	mov_number = @v_mov_number 
		AND stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number) */
	ELSE
		IF (SELECT COUNT(*) FROM stops WHERE [stp_type] ='DRP' and mov_number = @v_mov_number AND   stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA')) > 0 AND @v_isroundtrip = 'N' 
		INSERT INTO @company_profile			--CONSIGNEE
		SELECT	c.cmp_id,
			'CN',
			LEFT(c.cmp_name,50),
			ISNULL(LEFT(c.cmp_address1,50),''),
			ISNULL(LEFT(c.cmp_address2,50),''),
			LEFT(c.cty_nmstct, CHARINDEX(',',c.cty_nmstct,0)-1),
			SUBSTRING(c.cty_nmstct,CHARINDEX(',',c.cty_nmstct,0)+1,2),
			LEFT(c.cmp_country,3),
			ISNULL(c.cmp_aceidtype,'UNK'),
			ISNULL(c.cmp_aceid,' '),
			ISNULL(c.cmp_contact,' '),
			ISNULL(c.cmp_primaryphone,' '),
			' ',
			ISNULL(c.cmp_zip,' '),
			s.ord_hdrnumber,
			0
		FROM	company c
			JOIN stops s
				ON s.cmp_id = c.cmp_id
		WHERE	s.ord_hdrnumber in (Select ord_hdrnumber from stops where mov_number = @v_mov_number and ord_hdrnumber > 0)
			AND stp_type = 'DRP'
			AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA')
				
		
			/*SELECT	 @v_consignee =  cmp_id 		--consignee
			FROM	 stops 
			WHERE	 stp_type = 'DRP' 
					and stp_sequence = (SELECT MAX(stp_sequence) FROM stops	WHERE ord_hdrnumber = @v_ord_hdrnumber	AND stp_type = 'DRP')
					and ord_hdrnumber = @v_ord_hdrnumber	*/
		ELSE	--get consignee from any drop stops. Used also for in-transit moves PTS41005
		INSERT INTO @company_profile			--CONSIGNEE
		SELECT	c.cmp_id,
			'CN',
			LEFT(c.cmp_name,50),
			ISNULL(LEFT(c.cmp_address1,50),''),
			ISNULL(LEFT(c.cmp_address2,50),''),
			LEFT(c.cty_nmstct, CHARINDEX(',',c.cty_nmstct,0)-1),
			SUBSTRING(c.cty_nmstct,CHARINDEX(',',c.cty_nmstct,0)+1,2),
			LEFT(c.cmp_country,3),
			ISNULL(c.cmp_aceidtype,'UNK'),
			ISNULL(c.cmp_aceid,' '),
			ISNULL(c.cmp_contact,' '),
			ISNULL(c.cmp_primaryphone,' '),
			' ',
			ISNULL(c.cmp_zip,' '),
			s.ord_hdrnumber,
			0
		FROM	company c
			JOIN stops s
				ON s.cmp_id = c.cmp_id
		WHERE	s.ord_hdrnumber in (select ord_hdrnumber from stops where mov_number = @v_mov_number and ord_hdrnumber > 0)
			AND stp_type = 'DRP'
			--AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA')			
			
			
			/*SELECT	 @v_consignee =  cmp_id 		--consignee
			FROM	 stops 
			WHERE	 stp_type = 'DRP' 
					and stp_sequence = (SELECT MAX(stp_sequence) FROM stops s Join company c on s.cmp_id = c.cmp_id	WHERE ord_hdrnumber = @v_ord_hdrnumber	AND stp_type = 'DRP' and c.cmp_state in (select stc_state_c from statecountry where stc_country_c = 'USA'))
					and ord_hdrnumber = @v_ord_hdrnumber		*/	

	SELECT	 @v_broker =  cmp_id 		--broker
	FROM	 stops 
	WHERE	 stp_event in ('BCST','NBCST') 
			and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops	INNER JOIN statecountry ON stp_state = stc_state_c AND stc_country_c = 'USA'
							WHERE mov_number = @v_mov_number AND stp_event in('BCST','NBCST')) --PTS#44804
			and mov_number = @v_mov_number
			--AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA')
			
	IF @v_ord_hdrnumber > 0
	SELECT @v_billto = ord_billto		--billto
	FROM	orderheader
	WHERE	ord_hdrnumber = @v_ord_hdrnumber




	IF (SELECT ISNULL(@v_billto,'UNKNOWN')) <> 'UNKNOWN'     
	INSERT INTO @company_profile			--BILLTO
	SELECT	@v_billto,
		'BT',
		LEFT(c.cmp_name,50),
		ISNULL(LEFT(c.cmp_address1,50),''),
		ISNULL(LEFT(c.cmp_address2,50),''),
		LEFT(c.cty_nmstct, CHARINDEX(',',c.cty_nmstct,0)-1),
		SUBSTRING(c.cty_nmstct,CHARINDEX(',',c.cty_nmstct,0)+1,2),
		LEFT(c.cmp_country,3),
		ISNULL(c.cmp_aceidtype,'UNK'),
		ISNULL(c.cmp_aceid,' '),
		ISNULL(c.cmp_contact,' '),
		ISNULL(c.cmp_primaryphone,' '),
		' ',
		ISNULL(c.cmp_zip,' '),
		0,
		0
	FROM	company c
	WHERE	c.cmp_id = @v_billto



	IF (SELECT ISNULL(@v_broker,'UNKNOWN')) <> 'UNKNOWN'
	INSERT INTO @company_profile			--BROKER
	SELECT	@v_broker,
		'CB',
		LEFT(c.cmp_name,50),
		ISNULL(LEFT(c.cmp_address1,50),''),
		ISNULL(LEFT(c.cmp_address2,50),''),
		LEFT(c.cty_nmstct, CHARINDEX(',',c.cty_nmstct,0)-1),
		SUBSTRING(c.cty_nmstct,CHARINDEX(',',c.cty_nmstct,0)+1,2),
		LEFT(c.cmp_country,3),
		ISNULL(c.cmp_aceidtype,'UNK'),
		ISNULL(c.cmp_aceid,' '),
		ISNULL(c.cmp_contact,' '),
		ISNULL(c.cmp_primaryphone,' '),
		' ',
		ISNULL(c.cmp_zip,' '),
		0,
		0
	FROM	company c
	WHERE	c.cmp_id = @v_broker
	

	
		

--PTS 32515 Update #company_profile table with email addresses

UPDATE @company_profile 
SET	cmp_email = (SELECT TOP 1 email_address)
FROM	companyemail ce,@company_profile cp
WHERE	cp.cmp_id = ce.cmp_id
	AND ISNULL(ce.mail_default,'Y') = 'Y'  
	AND ISNULL(ce.type,'E') = 'E'
	
--PTS 41340 Update records and add the ord_number
UPDATE	@company_profile
SET	ord_number = o.ord_number
FROM	orderheader o
	INNER JOIN @company_profile c
		ON	o.ord_hdrnumber = c.ord_hdrnumber
WHERE 	o.ord_hdrnumber > 0
 	
--PTS 39508; remove any records that do not belong to the current ace movement

--remove any freight that is not associated with the main movement passed in
delete from @company_profile where cmp_role<> 'CB' AND ord_hdrnumber NOT IN( SELECT ord_hdrnumber FROM stops WHERE stp_type ='DRP' and mov_number = @v_mov_number)
	
--remove any orders that do not originate outside the US
DELETE FROM @company_profile WHERE cmp_role <> 'CB'  AND ord_hdrnumber NOT IN(SELECT ord_hdrnumber FROM stops 
				inner join #movs on stops.mov_number = #movs.mov_number
				inner join statecountry on stops.stp_state = stc_state_c
				 WHERE	stc_country_c <> 'USA'
						and stops.stp_type = 'PUP')



SELECT 
	cmp_id,
	cmp_role ,
	cmp_name,
	cmp_address1,
	cmp_address2,
	cmp_city,
	cmp_state,
	cmp_country,
	cmp_aceidtype,
	cmp_aceid,
	cmp_contact,
	cmp_phone,
	cmp_email,
	cmp_zip,
	ord_number	--41340
FROM @company_profile    


GO
GRANT EXECUTE ON  [dbo].[d_ace_companydata] TO [public]
GO
