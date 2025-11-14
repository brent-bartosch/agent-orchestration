# Testing Guide

This guide covers how to write automatic tests with Claude Code, perform manual testing, verify agent output, and set up integration testing.

---

## Overview

Testing is a critical part of the agent workflow. All code changes should be tested before being marked as complete.

### Testing Philosophy

1. **Test early, test often** - Don't wait until the end
2. **Automate what you can** - Manual testing is expensive
3. **Test with real data** - Synthetic data misses edge cases
4. **Log everything** - Test results should be traceable

---

## How to Write Automatic Tests with Claude Code

### Test-Driven Development Pattern

When Claude Code is working on a task:

1. **Write the test first** (or at least think through it)
2. **Implement the code**
3. **Run the test**
4. **Iterate until passing**
5. **Log results to the issue**

### Example: Testing a Scraper Function

#### Step 1: Create Test File

```bash
# In your project directory
mkdir -p tests
touch tests/scraper.test.ts
```

#### Step 2: Write Test Cases

```typescript
// tests/scraper.test.ts
import { describe, it, expect } from 'vitest';
import { extractProductTitle, extractPrice } from '../src/scraper';

describe('Product Scraper', () => {
  it('should extract product title correctly', () => {
    const html = '<h1 class="product-title">  Gaming Laptop  </h1>';
    const result = extractProductTitle(html);
    expect(result).toBe('Gaming Laptop');
  });

  it('should handle missing title gracefully', () => {
    const html = '<div>No title here</div>';
    const result = extractProductTitle(html);
    expect(result).toBeNull();
  });

  it('should extract price from various formats', () => {
    expect(extractPrice('$99.99')).toBe(99.99);
    expect(extractPrice('Price: $1,234.56')).toBe(1234.56);
    expect(extractPrice('€50.00')).toBe(50.00);
  });

  it('should return null for invalid prices', () => {
    expect(extractPrice('Free')).toBeNull();
    expect(extractPrice('')).toBeNull();
  });
});
```

#### Step 3: Run Tests

```bash
# Run all tests
pnpm test

# Run specific test file
pnpm test tests/scraper.test.ts

# Run with coverage
pnpm test --coverage

# Watch mode (for development)
pnpm test --watch
```

#### Step 4: Log Results to Issue

```bash
# Capture test output
pnpm test > test-results.txt 2>&1

# Post to issue
gh issue comment <issue-number> --body "$(cat <<'EOF'
## Test Results - $(date +%Y-%m-%d\ %H:%M)

\`\`\`
$(cat test-results.txt)
\`\`\`

**Summary:** All tests passing ✅
**Coverage:** 87%
**Next:** Moving to integration tests
EOF
)"
```

---

## Manual Testing

Sometimes automated tests aren't enough. Here's how to perform manual testing effectively.

### When to Test Manually

- **Visual output** - Rendered HTML, PDFs, images
- **Interactive features** - Forms, clicks, navigation
- **Real website integration** - Actual site behavior
- **Edge cases** - Unusual data or site states
- **Performance** - Load times, memory usage

### Manual Testing Checklist

For scrapers:

```markdown
## Manual Test Checklist

**Target Website:** retailer.com
**Date:** 2025-11-14
**Tester:** Claude Code

### Test Scenarios

- [ ] Single product page
- [ ] Product listing page (10+ items)
- [ ] Empty search results
- [ ] Product out of stock
- [ ] Product with sale price
- [ ] Product with variants (sizes/colors)
- [ ] Mobile version of site
- [ ] Site with CAPTCHA
- [ ] Site with rate limiting

### Results

| Scenario | Status | Notes |
|----------|--------|-------|
| Single product | ✅ Pass | Title and price extracted correctly |
| Listing page | ✅ Pass | All 12 products captured |
| Empty results | ⚠️ Partial | Returns empty array, should log warning |
| Out of stock | ✅ Pass | Correctly marked as unavailable |
| Sale price | ❌ Fail | Only captures original price, not sale price |
| With variants | ✅ Pass | All variants captured |
| Mobile | ✅ Pass | Selectors work on mobile view |
| CAPTCHA | ⏸️ Skipped | Using stealth mode, CAPTCHA not triggered |
| Rate limit | ✅ Pass | Automatic retry with backoff works |

### Issues Found

- **Sale price extraction failing:** Need to update selector to handle both regular and sale prices
- **Empty results logging:** Should log INFO level message when no results

### Next Steps

- Fix sale price selector
- Add logging for empty results
- Re-test failed scenarios
```

### Recording Manual Tests

```bash
# Create test log file
mkdir -p logs/manual-tests
touch logs/manual-tests/$(date +%Y%m%d-%H%M%S)-scraper-test.md

# Document your testing in the file
# Then commit it
git add logs/manual-tests/
git commit -m "Add manual test results for scraper"
```

---

## How to Verify Agent Output

### Verification Checklist

When an agent completes a task:

#### 1. **Code Quality**

- [ ] Code follows project style guide
- [ ] No obvious bugs or errors
- [ ] Proper error handling
- [ ] Comments where necessary
- [ ] No hard-coded values that should be configurable

#### 2. **Functionality**

- [ ] Feature works as described
- [ ] Edge cases handled
- [ ] No regressions (existing features still work)
- [ ] Performance is acceptable

#### 3. **Testing**

- [ ] Tests exist for new code
- [ ] Tests are passing
- [ ] Coverage meets project standards
- [ ] Test names are descriptive

#### 4. **Documentation**

- [ ] README updated if needed
- [ ] Code comments added
- [ ] API docs updated
- [ ] Examples provided if appropriate

#### 5. **Integration**

- [ ] Works with existing code
- [ ] No conflicts with other changes
- [ ] Dependencies properly declared
- [ ] Environment variables documented

### Verification Script

```bash
#!/bin/bash
# verify-agent-output.sh

echo "🔍 Verifying Agent Output..."
echo ""

# 1. Run linter
echo "1. Running linter..."
pnpm lint
if [ $? -ne 0 ]; then
  echo "❌ Linting failed"
  exit 1
fi
echo "✅ Linting passed"

# 2. Run type check
echo "2. Running type check..."
pnpm type-check
if [ $? -ne 0 ]; then
  echo "❌ Type check failed"
  exit 1
fi
echo "✅ Type check passed"

# 3. Run tests
echo "3. Running tests..."
pnpm test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed"
  exit 1
fi
echo "✅ Tests passed"

# 4. Check coverage
echo "4. Checking coverage..."
pnpm test --coverage --reporter=json > coverage.json
COVERAGE=$(cat coverage.json | jq '.total.lines.pct')
if [ $(echo "$COVERAGE < 80" | bc) -eq 1 ]; then
  echo "⚠️  Coverage is $COVERAGE% (target: 80%)"
else
  echo "✅ Coverage is $COVERAGE%"
fi

# 5. Build check
echo "5. Running build..."
pnpm build
if [ $? -ne 0 ]; then
  echo "❌ Build failed"
  exit 1
fi
echo "✅ Build passed"

echo ""
echo "✅ All verification checks passed!"
```

---

## Integration Testing (Future)

### Vision

Integration tests verify that different components work together correctly.

### Test Pyramid

```
         ┌───────────┐
         │    E2E    │  ← Few, slow, comprehensive
         └───────────┘
       ┌───────────────┐
       │  Integration  │  ← Some, medium speed
       └───────────────┘
    ┌──────────────────────┐
    │      Unit Tests      │  ← Many, fast, focused
    └──────────────────────┘
```

### Integration Test Example (Future)

```typescript
// tests/integration/scraper-pipeline.test.ts
import { describe, it, expect } from 'vitest';
import { runScraper } from '../src/scraper';
import { saveToSupabase } from '../src/database';
import { validateData } from '../src/validator';

describe('Scraper Pipeline Integration', () => {
  it('should scrape, validate, and save data end-to-end', async () => {
    // 1. Run scraper
    const results = await runScraper('https://test-site.com');
    expect(results).toHaveLength(10);

    // 2. Validate results
    const validData = await validateData(results);
    expect(validData.errors).toHaveLength(0);

    // 3. Save to Supabase
    const saved = await saveToSupabase(validData.data);
    expect(saved.success).toBe(true);

    // 4. Verify in database
    const fromDb = await supabase
      .from('products')
      .select('*')
      .eq('source', 'test-site.com')
      .gte('created_at', new Date(Date.now() - 1000).toISOString());

    expect(fromDb.data).toHaveLength(10);
  });
});
```

### E2E Testing (Future)

For testing full workflows including browser automation:

```typescript
// tests/e2e/scraper.spec.ts
import { test, expect } from '@playwright/test';

test('scraper workflow end-to-end', async ({ page }) => {
  // Navigate to target site
  await page.goto('https://retailer.com');

  // Perform search
  await page.fill('input[name="search"]', 'laptop');
  await page.click('button[type="submit"]');

  // Wait for results
  await page.waitForSelector('.product-card');

  // Extract data
  const products = await page.$$eval('.product-card', cards =>
    cards.map(card => ({
      title: card.querySelector('.title')?.textContent?.trim(),
      price: card.querySelector('.price')?.textContent?.trim()
    }))
  );

  // Verify data structure
  expect(products.length).toBeGreaterThan(0);
  expect(products[0]).toHaveProperty('title');
  expect(products[0]).toHaveProperty('price');
});
```

---

## Testing Best Practices

### ✅ DO:

- **Test edge cases** - null, empty, malformed data
- **Test error conditions** - network failures, timeouts, bad responses
- **Use descriptive test names** - `it('should extract price from $99.99 format')`
- **Keep tests focused** - one thing per test
- **Use test data fixtures** - reusable sample data
- **Clean up after tests** - don't leave test data in databases
- **Run tests before committing** - catch issues early
- **Document test coverage gaps** - what isn't tested and why

### ❌ DON'T:

- **Test implementation details** - test behavior, not internals
- **Write flaky tests** - tests should be deterministic
- **Skip tests to make CI pass** - fix the problem
- **Test third-party code** - trust their tests
- **Hard-code values** - use constants or config
- **Ignore test failures** - every failure is important

---

## Test Result Reporting

### Format for Issue Comments

```markdown
## Test Results - YYYY-MM-DD HH:MM

**Test Suite:** Unit Tests
**Duration:** 2.3s
**Status:** ✅ PASSING / ⚠️ PARTIAL / ❌ FAILING

### Summary

- **Total:** 45 tests
- **Passed:** 43
- **Failed:** 2
- **Skipped:** 0
- **Coverage:** 87%

### Failed Tests

1. `extractPrice should handle Euro format`
   - Expected: 50.00
   - Received: null
   - File: tests/scraper.test.ts:45

2. `handleRateLimit should retry with backoff`
   - Error: Timeout after 30s
   - File: tests/scraper.test.ts:78

### Next Steps

- [ ] Fix Euro price extraction
- [ ] Increase timeout for rate limit test
- [ ] Re-run full suite
```

---

## Continuous Integration (Future)

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test -- --coverage
      - run: npm run build

      # Post results to issue
      - name: Comment Test Results
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const results = fs.readFileSync('test-results.txt', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## CI Test Results\n\n\`\`\`\n${results}\n\`\`\``
            });
```

---

## Quick Reference

```bash
# Run all tests
pnpm test

# Run with coverage
pnpm test --coverage

# Run specific file
pnpm test path/to/test.ts

# Watch mode
pnpm test --watch

# Update snapshots
pnpm test --update

# Run linter
pnpm lint

# Type check
pnpm type-check

# Full verification
./scripts/verify-agent-output.sh
```

---

## Next Steps

- Set up test framework in your project
- Write tests for existing code
- Add CI/CD pipeline
- Document test standards for your team
- Review [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) for how testing fits into the overall workflow
