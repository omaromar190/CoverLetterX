import { type User } from 'wasp/entities';
import { logout } from 'wasp/client/auth';

import {
  stripePayment,
  stripeGpt4Payment,
  stripeCreditsPayment,
  useQuery,
  getUserInfo,
} from 'wasp/client/operations';

import BorderBox from './components/BorderBox';
import {
  Box,
  Heading,
  Text,
  Button,
  Code,
  Spinner,
  VStack,
  HStack,
  Link,
  Badge,
  Icon,
} from '@chakra-ui/react';

import { useState } from 'react';
import { IoWarningOutline } from 'react-icons/io5';
import { CheckIcon } from '@chakra-ui/icons';

export default function ProfilePage({ user }: { user: User }) {
  const [isLoading, setIsLoading] = useState(false);
  const [isGpt4loading, setIsGpt4Loading] = useState(false);
  const [isCreditsLoading, setIsCreditsLoading] = useState(false);

  const { data: userInfo } = useQuery(getUserInfo, { id: user.id });

  const userPaidOnDay = new Date(String(user.datePaid));
  const oneMonthFromDatePaid = new Date(
    userPaidOnDay.setMonth(userPaidOnDay.getMonth() + 1)
  );

  async function handleBuy4oMini() {
    setIsLoading(true);
    try {
      const response = await stripePayment();
      if (response.sessionUrl) window.open(response.sessionUrl, '_self');
    } catch {
      alert('Something went wrong. Please try again');
    }
    setIsLoading(false);
  }

  async function handleBuy4o() {
    setIsGpt4Loading(true);
    try {
      const response = await stripeGpt4Payment();
      if (response.sessionUrl) window.open(response.sessionUrl, '_self');
    } catch {
      alert('Something went wrong. Please try again');
    }
    setIsGpt4Loading(false);
  }

  async function handleBuyCredits() {
    setIsCreditsLoading(true);
    try {
      const response = await stripeCreditsPayment();
      if (response.sessionUrl) window.open(response.sessionUrl, '_self');
    } catch {
      alert('Something went wrong. Please try again');
    }
    setIsCreditsLoading(false);
  }

  const PlanFeature = ({ text }: { text: string }) => (
    <HStack spacing={2} align="start">
      <Icon as={CheckIcon} color="green.400" boxSize={3} mt="1" />
      <Text fontSize="sm">{text}</Text>
    </HStack>
  );

  return (
    <BorderBox>
      {!!userInfo ? (
        <>
          <Heading size="md" mb={3}>
            👋 Hi {userInfo.email || 'There'}
          </Heading>

          {userInfo.subscriptionStatus === 'past_due' ? (
            <VStack gap={3} py={5} alignItems="center">
              <Box color="purple.400">
                <IoWarningOutline size={30} color="inherit" />
              </Box>
              <Text textAlign="center" fontSize="sm" textColor="text-contrast-lg">
                Your subscription is past due. <br /> Please update your payment method{' '}
                <Link
                  textColor="purple.400"
                  href="https://billing.stripe.com/p/login/5kA7sS0Wc3gD2QM6oo"
                >
                  by clicking here
                </Link>
              </Text>
            </VStack>
          ) : userInfo.hasPaid && !userInfo.isUsingLn ? (
            <VStack gap={3} pt={5} alignItems="flex-start">
              <Text>Thanks so much for your support!</Text>
              <Text>
                You have unlimited access to CoverLetterX using{' '}
                {user?.gptModel === 'gpt-4' || user?.gptModel === 'gpt-4o'
                  ? 'GPT-4o.'
                  : 'GPT-4o-mini.'}
              </Text>

              {userInfo.subscriptionStatus === 'canceled' && (
                <Code fontSize="lg">
                  {oneMonthFromDatePaid.toUTCString().slice(0, -13)}
                </Code>
              )}

              <Text fontSize="sm" fontStyle="italic" color="gray.500">
                To manage your subscription,{' '}
                <Link
                  color="purple.600"
                  href="https://billing.stripe.com/p/login/5kA7sS0Wc3gD2QM6oo"
                >
                  click here.
                </Link>
              </Text>
            </VStack>
          ) : (
            !userInfo.isUsingLn && (
              <>
                <HStack pt={3}>
                  <Heading size="sm">You have</Heading>
                  <Code>{userInfo?.credits ?? '0'}</Code>
                  <Heading size="sm">
                    cover letter{userInfo?.credits === 1 ? '' : 's'} left
                  </Heading>
                </HStack>

                <VStack py={6} gap={6}>
                  <HStack
                    spacing={6}
                    wrap="wrap"
                    justify="center"
                    align="stretch"
                    w="100%"
                  >
                    {/* Standard Plan */}
                    <VStack
                      layerStyle="card"
                      p={6}
                      spacing={4}
                      width={{ base: '100%', md: '30%' }}
                      align="stretch"
                      justify="space-between"
                      height="100%"
                      minH="400px"
                    >
                      <Box>
                        <Heading size="md">Standard</Heading>
                        <Heading size="xl">$4</Heading>
                        <Text fontSize="sm">/ month</Text>
                        <PlanFeature text="Unlimited Cover Letters" />
                        <PlanFeature text="Inline Editing Tools" />
                        <PlanFeature text="Clever Generation (GPT-4o-mini)" />
                        <PlanFeature text="Draft Letters Faster" />
                      </Box>
                      <Button isLoading={isLoading} onClick={handleBuy4oMini}>
                        Choose Plan
                      </Button>
                    </VStack>

                    {/* Premium Plan */}
                    <VStack
                      layerStyle="cardMd"
                      borderColor="purple.300"
                      borderWidth={2}
                      p={6}
                      spacing={4}
                      width={{ base: '100%', md: '30%' }}
                      align="stretch"
                      justify="space-between"
                      height="100%"
                      minH="400px"
                    >
                      <Box>
                        <HStack justify="space-between" alignItems="center" wrap="wrap">
                          <Heading size="md">Premium</Heading>
                          <Badge
                            colorScheme="purple"
                            fontSize="0.7em"
                            px={2}
                            py={1}
                            borderRadius="full"
                            whiteSpace="nowrap"
                          >
                            Recommended
                          </Badge>
                        </HStack>
                        <Heading size="xl">$7</Heading>
                        <Text fontSize="sm">/ month</Text>
                        <PlanFeature text="Unlimited Cover Letters" />
                        <PlanFeature text="Inline Editing Tools" />
                        <PlanFeature text="Highest Quality (GPT-4.1)" />
                        <PlanFeature text="Stand Out From the Crowd" />
                      </Box>
                      <Button
                        colorScheme="purple"
                        isLoading={isGpt4loading}
                        onClick={handleBuy4o}
                      >
                        Choose Plan
                      </Button>
                    </VStack>

                    {/* Credit Packs */}
                    <VStack
                      layerStyle="card"
                      p={6}
                      spacing={4}
                      width={{ base: '100%', md: '30%' }}
                      align="stretch"
                      justify="space-between"
                      height="100%"
                      minH="400px"
                    >
                      <Box>
                        <Heading size="md">Credit Packs</Heading>
                        <Heading size="xl">$2.00</Heading>
                        <Text fontSize="sm">One-time</Text>
                        <PlanFeature text="Pay per-letter" />
                        <PlanFeature text="Great for casual users" />
                        <PlanFeature text="No subscription required" />
                      </Box>
                      <Button
                        colorScheme="green"
                        isLoading={isCreditsLoading}
                        onClick={handleBuyCredits}
                      >
                        Buy Credits
                      </Button>
                    </VStack>
                  </HStack>
                </VStack>
              </>
            )
          )}

          {userInfo.isUsingLn && (
            <VStack py={3} gap={5}>
              <VStack py={3} gap={2}>
                <HStack display="grid" gridTemplateColumns="1fr">
                  <VStack
                    layerStyle="card"
                    py={5}
                    px={7}
                    gap={3}
                    justifyContent="center"
                    alignItems="center"
                  >
                    <Heading size="xl">⚡️</Heading>
                    <Text fontSize="md">
                      You have affordable, pay-per-use access to CoverLetterX with GPT-4o via
                      the Lightning Network
                    </Text>
                    <Text fontSize="sm">
                      Note: if you prefer a monthly subscription, please logout and sign in
                      with Google.
                    </Text>
                  </VStack>
                </HStack>
              </VStack>
            </VStack>
          )}

          <Button alignSelf="flex-end" size="sm" mt={5} onClick={() => logout()}>
            Logout
          </Button>
        </>
      ) : (
        <Spinner />
      )}
    </BorderBox>
  );
}
