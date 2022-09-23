SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[referencemasking_validation] (
   @billto            VARCHAR(8),
   @table             VARCHAR(30),
   @status            VARCHAR(6),
   @refnumbers        VARCHAR(1000),
   @chgtypes          VARCHAR(1000),
   @error             VARCHAR(255) OUTPUT
)
AS
DECLARE @pos              INTEGER,
        @pos2             INTEGER,
        @start            INTEGER,
        @reference        VARCHAR(50),
        @reftype          VARCHAR(6),
        @reftype2         VARCHAR(6),
        @refnumber        VARCHAR(30),
        @chtitemcode      VARCHAR(6),
        @refcount         INTEGER, 
        @st_status        VARCHAR(10),
        @btrcount         INTEGER,
        @btrctcount       INTEGER,
        @refname          VARCHAR(20),
        @refname2         VARCHAR(20),
        @validrefcount    INTEGER,
        @validrefcount2   INTEGER,
        @btrlogic         VARCHAR(3),
        @masklogic        VARCHAR(3),
        @masklogic2       VARCHAR(3),
        @reftypemask      VARCHAR(30),
        @reftypemask2     VARCHAR(30),
        @reftypemask3     VARCHAR(30),
        @reftypemask4     VARCHAR(30),
        @ret              INTEGER,
        @minid            INTEGER,
        @retmask1         INTEGER,
        @retmask2         INTEGER,
        @ref1valid        INTEGER,
        @ref2valid        INTEGER,
        @chtdesctiption   VARCHAR(30),
        @minstid          INTEGER

CREATE TABLE #statuses (
   st_id           INT IDENTITY(1,1) NOT NULL,
   st_status       VARCHAR(6)
)

CREATE TABLE #referencenumbers (
   ref_id          INT IDENTITY(1,1) NOT NULL,
   ref_type        VARCHAR(6),
   ref_number      VARCHAR(30)
)

CREATE TABLE #chargetypes (
   cht_itemcode    VARCHAR(6)
)

CREATE TABLE #billtoreference (
   btr_id          INT IDENTITY(1,1) NOT NULL,
   ref_type        VARCHAR(6),
   ref_name        VARCHAR(20), 
   btr_logic       VARCHAR(3), 
   btr_mask        VARCHAR(30),
   btr_masklogic   VARCHAR(3),
   btr_mask2       VARCHAR(30)
)

CREATE TABLE #billtoreferencechgtype (
   btrct_id        INT IDENTITY(1,1) NOT NULL,
   chg_type        VARCHAR(6),
   cht_description VARCHAR(30),        
   ref_type        VARCHAR(6),
   ref_name        VARCHAR(20),
   btrct_mask      VARCHAR(30)
)

IF @table = 'order'
BEGIN
   IF @status = 'AVL'
   BEGIN
      INSERT INTO #statuses (st_status) VALUES ('AVL')
   END
   IF @status = 'STD'
   BEGIN
      INSERT INTO #statuses (st_status) VALUES ('AVL')
      INSERT INTO #statuses (st_status) VALUES ('STD')
   END
   IF @status = 'CMP'
   BEGIN
      INSERT INTO #statuses (st_status) VALUES ('AVL')
      INSERT INTO #statuses (st_status) VALUES ('STD')
      INSERT INTO #statuses (st_status) VALUES ('CMP')
   END
END

IF @table = 'invoice'
BEGIN
   IF @status = 'HLD'
   BEGIN
      INSERT INTO #statuses (st_status) VALUES ('HLD')
   END
   IF @status = 'RTP'
   BEGIN
      INSERT INTO #statuses (st_status) VALUES ('HLD')
      INSERT INTO #statuses (st_status) VALUES ('RTP')
   END
END


-- Parse the ref numbers into a table from the @refnumbers parameter.
SET @start = 1
SET @pos = CHARINDEX('|', @refnumbers, @start)
WHILE @pos > 0 
BEGIN
   SET @reference = RTRIM(LTRIM(SUBSTRING(@refnumbers, @start, @pos - @start)))
   SET @pos2 = CHARINDEX('~', @reference, 1)
   IF @pos2 > 0
   BEGIN
      SET @reftype = RTRIM(LTRIM(LEFT(@reference, @pos2 - 1)))
      SET @refnumber = RTRIM(LTRIM(RIGHT(@reference, Len(@reference) - @pos2)))
      SELECT @refname = name
        FROM labelfile 
       WHERE labeldefinition = 'ReferenceNumbers' AND
             abbr = @reftype
      INSERT INTO #referencenumbers (ref_type, ref_number)
                             VALUES (@reftype, @refnumber)
   END
   SET @start = @pos + 1
   SET @pos = CHARINDEX('|', @refnumbers, @start)
END

--Parse the charge types into a table from the @chgtypes parameter.
SET @start = 1
SET @pos = CHARINDEX('|', @chgtypes, @start)
WHILE @pos > 0
BEGIN
   SET @chtitemcode = RTRIM(LTRIM(SUBSTRING(@chgtypes, @start, @pos - @start)))
   INSERT INTO #chargetypes (cht_itemcode)
                     VALUES (@chtitemcode)
   SET @start = @pos + 1
   SET @pos = CHARINDEX('|', @chgtypes, @start)
END

--Cycle through the statuses in the #statuses table and check for references and masking based on these statuses
SET @error = 'VALID'
SET @minstid = 0
WHILE 1=1
BEGIN
   SELECT @minstid = MIN(st_id)
     FROM #statuses
    WHERE st_id > @minstid

   IF @minstid IS NULL 
      BREAK

   SELECT @st_status = st_status
     FROM #statuses
    WHERE st_id = @minstid

   DELETE FROM #billtoreference

   INSERT INTO #billtoreference
   SELECT ref_type, labelfile.name, btr_logic, btr_mask, btr_masklogic, btr_mask2 FROM billtoreference
   JOIN labelfile ON billtoreference.ref_type = labelfile.abbr AND labelfile.labeldefinition = 'ReferenceNumbers'
   WHERE btr_billto = @billto AND btr_table = @table AND btr_status = @st_status
   ORDER BY btr_logic

   SELECT @btrcount = COUNT(*)
     FROM #billtoreference
   IF @btrcount > 0
   BEGIN
      -- Do the reference masking from the billtoreference table that has and/or logic
      IF @btrcount = 1
      BEGIN
         SELECT @reftype = ref_type,
                @refname = ref_name,
                @reftypemask = btr_mask,
                @masklogic = btr_masklogic,
                @reftypemask2 = btr_mask2
           FROM #billtoreference
         
         -- Check to see if the reference number type exists in the reference numbers already entered.
         SELECT @validrefcount = COUNT(*)
           FROM #referencenumbers
          WHERE ref_type = @reftype
         IF @validrefcount = 0
         BEGIN 
            SET @error = 'This billto requires a reference number of type ' + @refname + ' in order to save.'
            RETURN
         END

         -- Check to see if the reference type number matches either of the masks for the first reference type
         SET @minid = 0
         SET @retmask1 = -1
         SET @retmask2 = -1
         WHILE 1=1   
         BEGIN
            SELECT @minid = MIN(ref_id)
              FROM #referencenumbers
             WHERE ref_type = @reftype AND
                   ref_id > @minid

            IF @minid IS NULL
               BREAK

            SELECT @refnumber = ref_number
              FROM #referencenumbers
             WHERE ref_id = @minid

            IF @retmask1 < 0 
            BEGIN
               EXEC @retmask1 = validatemask @refnumber, @reftypemask
            END

            IF @reftypemask2 IS NOT NULL AND @retmask2 < 0
            BEGIN
               EXEC @retmask2 = validatemask @refnumber, @reftypemask2
            END
         END
      
         IF @masklogic IS NOT NULL
         BEGIN
            IF @masklogic = 'AND' AND (@retmask1 < 0 OR @retmask2 < 0)
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask + ' ' + @masklogic + ' a mask of ' + @reftypemask2 + ' in order to save.'
               RETURN
            END
            IF @masklogic = 'OR' AND @retmask1 < 0 AND @retmask2 < 0
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask + ' ' + @masklogic + ' a mask of ' + @reftypemask2 + ' in order to save.'
               RETURN
            END 
         END
         ELSE
         BEGIN
            IF @retmask1 < 0 
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask + ' in order to save.'
               RETURN
            END
         END
      END


      IF @btrcount = 2
      BEGIN
         SELECT @reftype = ref_type,
                @refname = ref_name,
                @reftypemask = btr_mask,
                @masklogic = btr_masklogic,
                @reftypemask2 = btr_mask2
           FROM #billtoreference
          WHERE btr_id = 1

         SELECT @reftype2 = ref_type,
                @refname2 = ref_name,
                @btrlogic = btr_logic,
                @reftypemask3 = btr_mask,
                @masklogic2 = btr_masklogic,
                @reftypemask4 = btr_mask2
           FROM #billtoreference
          WHERE btr_id = 2
      
         -- Check to see if the reference number types exist in the reference numbers already entered.
         SELECT @validrefcount = COUNT(*)
           FROM #referencenumbers
          WHERE ref_type = @reftype

         SELECT @validrefcount2 = COUNT(*)
           FROM #referencenumbers
          WHERE ref_type = @reftype2

         IF @btrlogic = 'AND' AND (@validrefcount = 0 OR @validrefcount2 = 0)
         BEGIN
            SET @error = 'This billto requires a reference number of type ' + @refname + ' and a reference number of type ' + @refname2 + ' in order to save.'
            RETURN
         END

         IF @btrlogic = 'OR' AND @validrefcount = 0 AND @validrefcount2 = 0
         BEGIN
            SET @error = 'This billto requires a reference number of type ' + @refname + ' or a reference number of type ' + @refname2 + ' in order to save.'
            RETURN
         END

         -- Check to see if the reference type number matches either of the masks for the first reference type
         SET @minid = 0
         SET @ref1valid = 0
         SET @retmask1 = -1
         SET @retmask2 = -1
         WHILE 1=1   
         BEGIN
            SELECT @minid = MIN(ref_id)
              FROM #referencenumbers
             WHERE ref_type = @reftype AND
                   ref_id > @minid

            IF @minid IS NULL
               BREAK

            SELECT @refnumber = ref_number
              FROM #referencenumbers
             WHERE ref_id = @minid

            IF @retmask1 < 0 
            BEGIN
               EXEC @retmask1 = validatemask @refnumber, @reftypemask
            END

            IF @reftypemask2 IS NOT NULL AND @retmask2 < 0
            BEGIN
               EXEC @retmask2 = validatemask @refnumber, @reftypemask2
            END
         END
      
         IF @masklogic IS NOT NULL
         BEGIN
            IF @masklogic = 'AND' AND (@retmask1 < 0 OR @retmask2 < 0)
            BEGIN
               SET @ref1valid = -1
            END
            IF @masklogic = 'OR' AND @retmask1 < 0 AND @retmask2 < 0
            BEGIN
               SET @ref1valid = -1
            END 
         END
         ELSE
         BEGIN
            IF @retmask1 < 0 
            BEGIN
               SET @ref1valid = -1
            END
         END

         -- Check to see if the reference type number matches either of the masks for the second reference type
         SET @minid = 0
         SET @ref2valid = 0
         SET @retmask1 = -1
         SET @retmask2 = -1 
         WHILE 1=1
         BEGIN
            SELECT @minid = MIN(ref_id)
              FROM #referencenumbers
             WHERE ref_type = @reftype2 AND
                   ref_id > @minid

            IF @minid IS NULL
               BREAK

            SELECT @refnumber = ref_number
              FROM #referencenumbers
             WHERE ref_id = @minid

            IF @retmask1 < 0
            BEGIN
               EXEC @retmask1 = validatemask @refnumber, @reftypemask3
            END
      
            IF @reftypemask4 IS NOT NULL AND @retmask2 < 0
            BEGIN
               EXEC @retmask2 = validatemask @refnumber, @reftypemask4
            END
         END
 
         IF @masklogic2 IS NOT NULL
         BEGIN
            IF @masklogic2 = 'AND' AND (@retmask1 < 0 OR @retmask2 < 0)
            BEGIN
               SET @ref2valid = -1
            END
            IF @masklogic2 = 'OR' AND @retmask1 < 0 AND @retmask2 < 0
            BEGIN
               SET @ref2valid = -1
            END
         END
         ELSE
         BEGIN
            IF @retmask1 < 0 
            BEGIN
               SET @ref2valid = -1
            END
         END
      
         --Use the btr_logic to determine if valid reference number masks are already entered.
         IF @btrlogic = 'AND' AND (@ref1valid < 0 OR @ref2valid < 0)
         BEGIN
            IF @masklogic IS NOT NULL
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask + ' ' + @masklogic + ' a mask of ' + @reftypemask2
            END
            ELSE
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask
            END
            IF @masklogic2 IS NOT NULL
            BEGIN
               SET @error = @error + ' AND a reference number of type ' + @refname2 + ' with a mask of ' + @reftypemask3 + ' ' + @masklogic2 + ' a mask of ' + @reftypemask4 + ' in order to save.'
            END
            ELSE
            BEGIN
               SET @error = @error + ' AND a reference number of type ' + @refname2 + ' with a mask of ' + @reftypemask3 + ' in order to save.'
            END
            RETURN
         END

         IF @btrlogic = 'OR' AND @ref1valid < 0 AND @ref2valid < 0
         BEGIN
            IF @masklogic IS NOT NULL
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask + ' ' + @masklogic + ' a mask of ' + @reftypemask2
            END         
            ELSE
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask
            END
            IF @masklogic2 IS NOT NULL
            BEGIN
               SET @error = @error + ' OR a reference number of type ' + @refname2 + ' with a mask of ' + @reftypemask3 + ' ' + @masklogic2 + ' a mask of ' + @reftypemask4 + ' in order to save.'
            END
            ELSE
            BEGIN
               SET @error = @error + ' OR a reference number of type ' + @refname2 + ' with a mask of ' + @reftypemask3 + ' in order to save.'
            END
            RETURN
         END 
      END
   END
   ELSE
   BEGIN
      SET @error = 'VALID'
   END


   -- Check for reference number masking tied to the billto and charge types on the order.
   DELETE FROM #billtoreferencechgtype

   INSERT INTO #billtoreferencechgtype
   SELECT chg_type, chargetype.cht_description, ref_type, labelfile.name, btrct_mask
   FROM billtoreferencechgtype JOIN #chargetypes ON billtoreferencechgtype.chg_type = #chargetypes.cht_itemcode
   JOIN labelfile ON billtoreferencechgtype.ref_type = labelfile.abbr AND labelfile.labeldefinition = 'ReferenceNumbers'
   JOIN chargetype ON billtoreferencechgtype.chg_type = chargetype.cht_itemcode
   WHERE btrct_billto = @billto AND btrct_table = @table AND btrct_status = @st_status

select * from #billtoreferencechgtype
   SELECT @btrctcount = COUNT(*)
     FROM #billtoreferencechgtype
   IF @btrctcount > 0
   BEGIN
      -- Cycle through the required reference numbers and masks from the #billtoreferencechgtype table and see if they match.
      SET @minid = 0
      WHILE 1=1 
      BEGIN
         SELECT @minid = MIN(btrct_id)
           FROM #billtoreferencechgtype
          WHERE btrct_id > @minid

         IF @minid IS NULL 
            BREAK

         SELECT @reftype = ref_type,
                @refname = ref_name,
                @reftypemask = btrct_mask,
                @chtdesctiption = cht_description
           FROM #billtoreferencechgtype
          WHERE btrct_id = @minid

         SELECT @refnumber = ref_number
           FROM #referencenumbers 
          WHERE ref_type = @reftype
         IF @refnumber IS NULL
         BEGIN
            SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask + 
                         ' when a charge type of ' + @chtdesctiption + ' is found on the order.'
            RETURN
         END
         ELSE
         BEGIN
            EXEC @retmask1 = validatemask @refnumber, @reftypemask
            IF @retmask1 < 0
            BEGIN
               SET @error = 'This billto requires a reference number of type ' + @refname + ' with a mask of ' + @reftypemask + 
                            ' when a charge type of ' + @chtdesctiption + ' is found on the order.'
               RETURN
            END
         END    
      END
   END
   ELSE 
   BEGIN
      SET @error = 'VALID'
   END
END

GO
GRANT EXECUTE ON  [dbo].[referencemasking_validation] TO [public]
GO
