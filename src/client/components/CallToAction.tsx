import { VStack, HStack, Text, Link, Divider } from '@chakra-ui/react';
import { FaTwitter } from 'react-icons/fa';
import { Link as WaspLink } from 'wasp/client/router';

export function Footer() {
  return (
    <VStack width='full' py={5} textAlign='center' gap={4}>
      <Divider />
      <VStack gap={3}>
        <Link href='https://twitter.com/coverletterx' target='_blank' color='purple.300'>
          <HStack justify='center'>
            <FaTwitter />
            <Text fontSize='sm' color='purple.300'>
              Follow me on Txitter
            </Text>
          </HStack>
        </Link>
        <WaspLink to='/tos'>
          <Text fontSize='sm' color='purple.300'>
            Terms of Service
          </Text>
        </WaspLink>
        <WaspLink to='/privacy'>
          <Text fontSize='sm' color='purple.300'>
            Privacy Policy
          </Text>
        </WaspLink>
      </VStack>
    </VStack>
  );
}
